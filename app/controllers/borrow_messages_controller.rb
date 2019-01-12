class BorrowMessagesController < ApplicationController

	include ApplicationHelper

	before_action :check_token, except: [:admin_messages, :load_admin_messages, :send_admin_message]
	before_action :set_data, except: [:admin_messages, :load_admin_messages, :send_admin_message]
	before_action :check_active, except: [:admin_messages, :load_admin_messages, :send_admin_message]
	before_action :check_privacy, only: [:admin_messages, :load_admin_messages, :send_admin_message]
	skip_before_action :verify_authenticity_token, only: [:create, :send_images]

	def index
		@messages = @borrow.borrow_message.where("status != :status", {status: "yb"}).order(created_at: :asc)
		render layout: false
	end

	def new
		@message = BorrowMessage.new
		render layout: false
	end

	def borrow_all
		@borrows = Array.new
		BorrowItemUser.all.order(created_at: :desc).each do |borrow|
			if borrow.user.id == session[:user_id] or borrow.item.user.id == session[:user_id] then
				@borrows.append(set_borrow_data(borrow))
			end
		end
		@active = params[:active]
		render layout: false
	end

	def create
		if @active == true then
			@message = @borrow.borrow_message.create(message_params)
			@message.sender_id = session[:user_id]
			@message.has_images = false
			if @message.save then
				render json: {"type" => "success", "text" => params[:message][:message]}
			else
				render json: {"type" => "error", "text" => @message.errors.full_messages}
			end
		else
			render json: {"type" => "error", "text" => "Your Private Account Is Npot Active !!!"}
		end
	end

	def send_images
		@message = @borrow.borrow_message.create(message_params)
		@message.sender_id = session[:user_id]
		@message.has_images = true
		if @active == true then
			if @message.save then
				images = params[:message][:images]
				if images.count > 0 then
					for image in images
						@image_message = BorrowMessageImage.new
						@image_message.borrow_message_id = @message.id
						@image_message.image = image
						if @image_message.save then
						else
							render json: {"type" => "error", "text" => @image_message.errors.full_messages}
						end
					end
				else
					@message.destroy
					render json: {"type" => "error", "text" => "Images cannot be null"}
				end
				render json: {"type" => "success", "text" => "Has sent Images !!!"}
			else
				render json: {"type" => "error", "text" => @message.errors.full_messages}
			end
		else
			render json: {"type" => "error", "text" => "Your Private Account Is Not Active !!!"}
		end
	end

	def destroy
	end

	def admin_messages
		@sender = session[:admin] != nil ? 0 : @borrow.user.id
		@receiver = session[:admin] != nil ? @borrow.user.id : 0 
		@with = session[:admin] != nil ? @borrow.user.username.capitalize! : "Yo Buddy" 
        render layout: false
    end

    def send_admin_message
    	@message = @borrow.borrow_message.create({
    		sender_id: params[:admin_message][:sender_id],
    		receiver_id: params[:admin_message][:receiver_id],
    		message: params[:admin_message][:message],
    		has_images: false,
    		status: "yb",
    		is_deleted: false
    	})
    	render json:{"type" => "success", "text" => params[:admin_message][:message]}
    end

    def load_admin_messages
        @messages = @borrow.borrow_message.where("receiver_id = 0 OR sender_id = 0").where("receiver_id = :borrower OR sender_id = :borrower", {borrower: @borrow.user.id}).order(created_at: :asc)
        render layout: false
    end

	private def message_params
		params.require(:message).permit(:message, :receiver_id, :is_deleted, :status)
	end

	private def set_borrow_data(borrow)
		item = Hash.new
		item["borrow"] = borrow
		item["unread"] = borrow.borrow_message.where(status: "unread", is_deleted: false, receiver_id: session[:user_id]).count
		return item
	end

	private def set_data
		@item = Item.find(params[:item_id]) if params[:item_id] != nil
		@borrow = @item.borrow_item_user.find(params[:item_borrow_user_id])
		if @item.user.id != session[:user_id] and @borrow.user.id != session[:user_id] then
            render json: {"type" => "error", "text" => "You are not the Owner !!!"}
        end
	end

	private def check_privacy
		@item = Item.find(params[:item_id]) if params[:item_id] != nil
		@borrow = @item.borrow_item_user.find(params[:item_borrow_user_id])
		if session[:admin] == nil then
			if @borrow.item.user.is_private? or @borrow.user.id != session[:user_id] then
				render json: {"type" => "error", "text" => "unauthorized"}
			end
		else
			admin =  Admin.find(session[:admin])
			if @borrow.admin.id != admin.id then
				if admin.privileges != "all" then
					render json: {"type" => "error", "text" => "unauthorized"}
				end
			end
		end
	end
end
