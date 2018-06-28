class AdminController < ApplicationController

	include AdminHelper
	include ApplicationHelper

	before_action :check_admin_session, except: [:index, :signup]
	skip_before_action :check_admin_session, only: [:index, :signup]
	before_action :set_data

	@@login_attempts = 0

	def index
		if is_admin_logged_in? then
			redirect_to admin_home_path
		end
	end

	def signup

		admin = Admin.where("email = :email OR username = :username", {email: params[:admin][:admin], username: params[:admin][:admin]}).first

		if @@login_attempts < 5 then
			if admin then
				if admin.authenticate(params[:admin][:password]) then
					login_admin admin
					flash[:success] = "Amin Logged In Successfully !!!"
					@@login_attempts = 0
					redirect_to admin_home_path
				else
					flash[:danger] = "Incorrect Password !!!"
					@@login_attempts += 1
					redirect_to admin_index_path
				end
			else
				flash[:danger] = "Incorrect Email or Username !!!"
				@@login_attempts += 1
				redirect_to admin_index_path
			end
		else
			flash[:danger] = "Try Later !!!"
			redirect_to root_path
		end
	end

	def home
		@items = Item.all.order(created_at: :desc).limit(20)
		@borrows = BorrowItemUser.all.order(created_at: :desc).limit(20)
	end

	def admins
		@new_admin = Admin.new
		@admins = Admin.all.order(name: :asc)
	end

	def create_admin
		@new_admin = Admin.new(params[:admin].permit(:name, :username, :email, :privileges, :password, :image))
		if @new_admin.save then
			flash[:success] = "Admin Added Successfully !!!"
		else
			flash[:danger] = @new_admin.errors.full_messages
		end
		redirect_to admin_admins_path
	end

	def items
		@items = AdminItem.all.order(created_at: :desc)
	end

	def item
		@item = Item.find(params[:id])
		@borrows = @item.borrow_item_user.all.order(created_at: :desc)
	end

	def borrows_all
		@borrows = BorrowItemUser.all.order(created_at: :desc)
	end

	def borrows_item
		@item = AdminItem.find(params[:id])
		@borrows = @item.item.borrow_item_user.all.order(created_at: :desc)
	end

	def scan_borrow
		render layout: false
	end

	def scan_borrow_post
		borrow = check_scan_data params[:borrow_scan][:data]
		if borrow != 0 then
			render json: {"type" => "success", "text" => admin_borrow_path(borrow.item, borrow)}
		else
			render json: {"type" => "error", "text" => "Borrow Not Found !!!"}
		end
	end

	def borrow
		@message = BorrowItemAdmin.new
		@borrow_item = ListBorrowItem.new
		@item = Item.find(params[:item_id])
		@borrow = @item.borrow_item_user.find(params[:id])
		@user_messages = @borrow.borrow_message.where("receiver_id = 0 AND sender_id = 0").order(created_at: :asc)
		@admin_messages = @borrow.borrow_item_admin.all
		@borrow_items = @borrow.list_borrow_item.all

		status = params[:status]
		state = params[:state]
		@page_status = 0

		if status == @borrow_admin_status[0] and state == 1 then
			@act = borrow_received_act @borrow
		elsif status == @borrow_admin_status[1] and state == 1 then
			@act = borrow_rendered_act @borrow
		end	
	end

	def add_item
		@borrow = BorrowItemUser.find(params[:id])
		@item = @borrow.list_borrow_item.create(params[:list_borrow_item].permit(:name, :state, :description))
		if @item.save then
			flash[:success] = "Item Added !!!"
		else
			flash[:danger] = @item.errors.full_messages
		end
		redirect_to admin_borrow_path(@borrow.item, @borrow)
	end

	def borrow_check_item
		@borrow = BorrowItemUser.find(params[:id])
		check_item = check_item_borrow(params[:item_scan][:code])
		if check_item != 0 and check_item != 1 then
			if @borrow.id == check_item.borrow_item_user.id then
				if check_item.is_returned? then
					render json: {"type" => "error", "text" => "Item Borrow Already Confirmed For This Borrow !!!" }
				else
					check_item.is_returned = true
					check_item.save
					render json: {"type" => "success", "text" => "Item Borrow Confirmed !!!", "item": check_item.id }
				end
			else
				render json: {"type" => "wrong", "text" => "Wrong Borrow. Redirecting...", "url" => admin_borrow_path(check_item.borrow_item_user.item, check_item.borrow_item_user) }
			end
		elsif check_item == 0 then
			render json: {"type" => "error", "text" => "Item Borrow Not Confirmed !!!" }
		elsif check_item == 1 then
			render json: {"type" => "error", "text" => "Item Borrow Not Rendered !!!" }
		end
	end

	def borrow_item_admin_create
		@borrow = BorrowItemUser.find(params[:id])
		@last =  @borrow.borrow_item_admin.last
		item = AdminItem.where(item_id: @borrow.item.id).first
		if Array[@status[1], @status[3], @status[4], @status[5]].include?(@borrow.status) then
			@message = @borrow.borrow_item_admin.create(params[:borrow_item_admin].permit(:status, :state, :comment))
			@message.admin_id = session[:admin]
			state = 0
			if item != nil then
				item.borrow_id = @borrow.id
				item.status = params[:borrow_item_admin][:status]
				if params[:borrow_item_admin][:status] == @borrow_admin_status[1] then
					if @last != nil then
						if item.is_available == true and @last.status == @borrow_admin_status[0] then
							if @message.save then
								item.is_available = false
								item.save
								state = 1
								flash[:success] = "Message Saved Successfully !!!"
							else 
								flash[:danger] =  @message.errors.full_messages
							end
						else
							flash[:danger] = "Item Is Alreay Rendered To #{item.borrow_item_user.user.name} !!!"
						end
					else
						flash[:danger] = "Item Not Found In Admin !!!"
					end
				else
					if @message.save then
						if params[:borrow_item_admin][:status] == @borrow_admin_status[0] then
							item.is_available = true
							item.save
							save_message(@status[3], @borrow)
						elsif params[:borrow_item_admin][:status] == @borrow_admin_status[2] then
							item.is_available = true
							item.save
							save_message(@status[4], @borrow)
						elsif params[:borrow_item_admin][:status] == @borrow_admin_status[4] then
							item.is_available = false
							item.save
							save_message(@status[5], @borrow)
						elsif params[:borrow_item_admin][:status] == @borrow_admin_status[5] then
							item.is_available = false
							item.save
							save_message(@status[6], @borrow)
						end
						flash[:success] = "Message Saved Successfully !!!"
					else
						flash[:danger] =  @message.errors.full_messages
					end
				end
			else
				admin_item = AdminItem.new
				admin_item.item_id = @borrow.item.id
				admin_item.borrow_id = @borrow.id
				admin_item.status = params[:borrow_item_admin][:status]

				if @message.save then
					if params[:borrow_item_admin][:status] == @borrow_admin_status[0] then
						admin_item.is_available = true
						admin_item.save
						save_message(@status[3], @borrow)
					elsif params[:borrow_item_admin][:status] == @borrow_admin_status[2] then
						admin_item.is_available = true
						admin_item.save
						save_message(@status[4], @borrow)
					elsif params[:borrow_item_admin][:status] == @borrow_admin_status[4] then
						admin_item.is_available = false
						admin_item.save
						save_message(@status[5], @borrow)
					elsif params[:borrow_item_admin][:status] == @borrow_admin_status[5] then
						admin_item.is_available = false
						admin_item.save
						save_message(@status[6], @borrow)
					end
					state = 1
					flash[:success] = "Message Saved Successfully !!!"
				else 
					flash[:danger] =  @message.errors.full_messages
				end

			end
			redirect_to admin_borrow_path(@borrow.item, @borrow) + "?status=#{params[:borrow_item_admin][:status]}&state=#{state}"
		else
			flash[:danger] = "Only allowed if status is Accepted"
			redirect_to admin_borrow_path(@borrow.item, @borrow)
		end
	end

	def borrow_act_received
		@borrow = BorrowItemUser.find(params[:id])
		@act = borrow_received_act @borrow
		render layout: false
	end

	def borrow_act_rendered
		@borrow = BorrowItemUser.find(params[:id])
		@act = borrow_rendered_act @borrow
		render layout: false
	end

	def categories
		@categories = Category.all.order(name: :asc)
	end

	def new_category
		@category = Category.new
		render layout: false
	end

	def create_category
		@category = Category.create(params[:category].permit(:name, :description))
		@category.uuid = generate_uuid(params[:category][:name])
		if @category.save then
			flash[:success] = "Category Added Successfully !!!"
		else
			flash[:danger] = @category.errors.full_messages
		end
		redirect_to admin_categories_path
	end

	def category
		@category = Category.find(params[:id])
		@categories = Category.all.order(name: :asc)
		@subcategories = @category.subcategory.all.order(name: :asc)
	end

	def edit_category
		@category = Category.find(params[:id])
		render layout: false
	end

	def update_category
		@category = Category.find(params[:id])
		@category.uuid = generate_uuid(params[:category][:name])
		if @category.update(params[:category].permit(:name, :description)) then
			flash[:success] = "Category Updated Successfully !!!"
		else
			flash[:danger] = @category.errors.full_messages
		end
		redirect_to admin_category_path(@category)
	end

	def subcategories
		@subcategories = Subcategory.all.order(name: :asc)
	end

	def new_subcategory
		@category = Category.find(params[:category_id])
		@categories = Category.all.order(name: :asc)
		@subcategory = Subcategory.new
		render layout: false
	end
	
	def create_subcategory
		@category = Category.find(params[:subcategory][:category_id])
		@subcategory = @category.subcategory.create(params[:subcategory].permit(:name))
		@subcategory.uuid = generate_uuid(params[:subcategory][:name])
		if @subcategory.save then
			flash[:success] = "Subcategory Added Successfully !!!"
		else
			flash[:danger] = @subcategory.errors.full_messages
		end
		redirect_to admin_category_path(@category)
	end

	def subcategory
		@category = Category.find(params[:category_id])
		@subcategory = @category.subcategory.find(params[:id])
		@items = @subcategory.item.all.order(created_at: :desc)
	end
	
end
