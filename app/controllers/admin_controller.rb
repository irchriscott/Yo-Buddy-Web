require 'securerandom'

class AdminController < ApplicationController

	include AdminHelper
	include ApplicationHelper
	include ItemBorrowUserHelper

	before_action :check_admin_session, except: [:index, :signup, :reset_password, :reset_password_form, :send_reset_password_mail, :reset_change_password]
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
					flash[:success] = "Admin Logged In Successfully !!!"
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
		@items = Item.joins("INNER JOIN users ON items.user_id = users.id").where("users.is_private = ?", false).order(created_at: :desc).limit(20)
		@borrows = BorrowItemUser.joins("INNER JOIN items ON borrow_item_users.item_id = items.id INNER JOIN users ON items.user_id = users.id").where("users.is_private = ?", false).order(created_at: :desc).limit(20)
		
		@rendered = to_be_rendered(Time.now.to_date).count
		@returned = to_be_returned(Time.now.to_date).length
		
		@late_render = late_to_be_rendered(Time.now.to_date).length
		@late_receive = late_to_be_received(Time.now.to_date).length
		@late_return = late_to_be_returned(Time.now).length
	end

	def admins
		@new_admin = Admin.new
		@admins = Admin.all.order(name: :asc)
		@admin_users = AdminUser.all.order(created_at: :desc)
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
		@items = AdminItem.joins("INNER JOIN items ON admin_items.item_id = items.id INNER JOIN users ON items.user_id = users.id").where("users.is_private = ? ", false).order(created_at: :desc)
	end

	def item
		@item = Item.find(params[:id])
		@borrows = @item.borrow_item_user.all.order(created_at: :desc)
	end

	def borrows_all
		@borrows = BorrowItemUser.joins("INNER JOIN items ON borrow_item_users.item_id = items.id INNER JOIN users ON items.user_id = users.id").where("users.is_private = ?", false).order(created_at: :desc)
	end

	def borrows_item
		@item = AdminItem.find(params[:id])
		@borrows = @item.item.borrow_item_user.all.order(created_at: :desc)
		if @item.item.user.is_private? then
			flash[:error] = "401 => Unauthorized !!!"
			redirect_to admin_borrows_all_path
		end
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

		if @item.user.is_private? then
			flash[:error] = "401 => Unauthorized !!!"
			redirect_to admin_borrows_all_path
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
		@act = borrow_received_act(@borrow, session_admin.name)
		render layout: false
	end

	def borrow_act_rendered
		@borrow = BorrowItemUser.find(params[:id])
		@act = borrow_rendered_act(@borrow, session_admin.name)
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

	def search_user
		@users = User.where(is_private: true).where("name LIKE ? OR username LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%").order(created_at: :desc)
	end

	def create_admin_user
		user = User.find(params[:admin_user][:user_id])
		if user.name == params[:admin_user][:name] and user.is_private == true then
			if user.admin_user == nil then
				
				password = SecureRandom.urlsafe_base64(8)
				
				admin_user = AdminUser.new
				admin_user.user_id = user.id
				admin_user.email = user.email
				admin_user.password = password
				admin_user.privileges = "All"
				admin_user.save
				
				activation = AdminUserActivation.new
				activation.admin_user_id = admin_user.id
				activation.key_type = "trial"
				activation.max_items = 0
				activation.max_users = 0
				activation.activated_date = Time.now
				activation.expary_date = Time.now + (AdminHelper::TRIAL_NUM_DAYS * 24 * 60 * 60)
				activation.is_active = true
				activation.save

				AdminMailer.register_admin_user(user.email, password).deliver_now

				flash[:success] =  "Admin User Created Successfully !!!"
			else
				flash[:danger] = "User Already Has Admin Account !!!"
			end
		else
			flash[:danger] = "User Should Be Private !!!"
		end
		redirect_to admin_admins_path
	end

	def reset_password
    end

    def send_reset_password_mail
    	respond_to do |format|
            admin = Admin.find_by(email: params[:email][:email])
            if admin != nil then
                token = SecureRandom.urlsafe_base64(admin.name.length)
                rsp_check = ResetPassword.where(resource: "admin", resource_id: admin.id).first

                if rsp_check != nil then
                    rsp_check.token = token
                    rsp_check.is_active = true
                    rsp_check.expiry_date = get_expiry_date(1)
                    rsp_check.count += 1
                    rsp_check.save
                else
                    ResetPassword.create([{resource: "admin", resource_id: admin.id, email: params[:email][:email], token: token, expiry_date: get_expiry_date(1), is_active: true, count: 1 }])
                end

                ResetPasswordMailer.send_link(params[:email][:email], admin_rp_link_url(token)).deliver_now

                flash[:success] = "Link Sent To The Email Address !!!";
                format.html { redirect_to admin_index_path }
                format.json { render json: { "type" => "success", "text" => "Link Sent To The Email Address !!!" } }
            else
                flash[:danger] = "Unknown Email Address !!!";
                format.html { redirect_to admin_reset_password_path }
                format.json { render json: { "type" => "error", "text" => "Unknown Email Address !!!" } }
            end
        end
    end

    def reset_password_form
    	rsp = ResetPassword.find_by(token: params[:token])
        if rsp != nil then
            if rsp.is_active? then
            	@token = params[:token]
            else
                flash[:danger] = "Token Desactivated. Resend Email Please !!!";
                redirect_to admin_reset_password_path
            end
        else
            flash[:error] = "Unknown Token !!!"
            redirect_to admin_reset_password_path
        end
    end

    def reset_change_password
    	rsp = ResetPassword.find_by(token: params[:new_pswd][:rsp_token])
    	if params[:new_pswd][:password] == params[:new_pswd][:conf_password] then

    		admin = Admin.find(rsp.resource_id)
    		admin.password = params[:new_pswd][:password]
    		admin.save

    		rsp.is_active = false
    		rsp.save
    		
    		flash[:success] = "Password Changed !!!"
    		redirect_to admin_index_path
    	else
    		flash[:danger] = "Password Didnt Match !!!"
    		redirect_to admin_rp_link_path(rsp.token)
    	end
    end
	
end
