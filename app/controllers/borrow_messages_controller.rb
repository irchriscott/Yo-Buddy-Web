class BorrowMessagesController < ApplicationController

	before_action :set_data

	def index
		@messages = @borrow.borrow_message.all.order(created_at: :asc)
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
		@message = @borrow.borrow_message.create(message_params)
		@message.sender_id = session[:user_id]
		@message.has_images = false
		if @message.save then
			render json: {"type" => "success", "text" => params[:message][:message]}
		else
			render json: {"type" => "error", "text" => @message.errors.full_messages}
		end
	end

	def send_images
		@message = @borrow.borrow_message.create(message_params)
		@message.sender_id = session[:user_id]
		@message.has_images = true
		if @message.save then
			images = params[:message][:images]
			for image in images
				@image_message = BorrowMessageImage.new
				@image_message.borrow_message_id = @message.id
				@image_message.image = image
				if @image_message.save then
				else
					render json: {"type" => "error", "text" => @image_message.errors.full_messages}
				end
			end
			render json: {"type" => "success", "text" => "Has sent Images !!!"}
		else
			render json: {"type" => "error", "text" => @message.errors.full_messages}
		end
	end

	def destroy
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
end
