class SessionController < ApplicationController

	before_action :set_session
	before_action :set_data_items_counts
	
	def index
		if is_logged_in? then
			@items = Item.where(user_id: session[:user_id]).order('created_at DESC')
		else
			redirect_to controller: 'user', action: 'new'
		end
	end

	def borrowed
		items = @user.item.all
		@items = Array.new
		items.each do |item|
			if item.borrow_item_user.count > 0 then
				@items.append(get_borrow_item_data(item))
			end
		end
		@activate = "borrowed"
	end

	def borrowing
		@borrows = BorrowItemUser.where(user_id: session[:user_id]).order(created_at: :desc)
		@activate = "borrowing"
	end
	
	def favourites
		@favourites = @user.item_favourite.all.order(created_at: :desc)
		@activate = "favourites"
	end

	def requests
		@requests = @user.item_request.all.order(to_date: :asc)
		@activate = "requests"
	end

	def likes
		@likes = @user.item_like.all.order(created_at: :desc)
	end
	
	def followers
		@followers = UserFollow.where(following_id: @user.id)
	end

	def following
		@following = UserFollow.where(user_id: @user.id)
	end

	def edit
	end

	def update_image
		respond_to do |format|
			if @user.update(params.require(:user).permit(:image)) then
				format.html { redirect_to session_edit_path, success: 'User Image Updated !!!' }
                format.json { render json: {"type" => "success", "text" => "User Image Updated !!!"} , status: :updated, location: @user }
				flash[:success] = "User Image Updated !!!"
			else
				format.html { render 'new', danger: @user.errors.full_messages }
                format.json { render json: {"type" => "success", "text" => @user.errors}, status: :unprocessable_entity }
				flash[:danger] = @user.errors.full_messages
			end
		end
	end

	def update_info
		respond_to do |format|
			if @user.authenticate(params[:user][:password]) then

				@user.username = params[:user][:username]
				@user.name = params[:user][:name]

				if @user.username != params[:user][:username] then
					check_user_username = User.find_by username: params[:user][:username]
					if !check_user_username then
						if @user.save then
							format.html { redirect_to session_edit_path, success: 'User Info Updated !!!' }
                			format.json { render json: {"text" => "User Info Updated !!!"} , status: :updated, location: @user }
							flash[:success] = 'User Info Updated !!!'
						else
							format.html { redirect_to session_edit_path, danger: @user.errors.full_messages }
                			format.json { render json: {"type" => "error", "text" => @user.errors}, status: :unprocessable_entity }
                			flash[:danger] = @user.errors.full_messages
						end
					else
						format.html { redirect_to session_edit_path, danger: "Username Already Taken !!!" }
                		format.json { render json: {"type" => "error", "text" => "Username Already Taken !!!"}, status: :unprocessable_entity }
						flash[:danger] = 'Username Already Taken !!!'
					end
				else
					if @user.save then
						format.html { redirect_to session_edit_path, success: 'User Info Updated !!!' }
                		format.json { render json: {"type" => "success", "text" => "User Info Updated !!!"} , status: :updated, location: @user }
						flash[:success] = 'User Info Updated !!!'
					else
						format.html { redirect_to session_edit_path, danger: @user.errors.full_messages }
                		format.json { render json: {"type" => "error", "text" => @user.errors}, status: :unprocessable_entity }
                		flash[:danger] = @user.errors.full_messages
					end
				end
			else
				format.html { redirect_to session_edit_path, danger: 'Wrong Password !!!' }
               	format.json { render json: {"type" => "error", "text" => "Wrong Password !!!"}, status: :unprocessable_entity }
				flash[:danger] = "Wrong Password !!!"
			end
		end
	end

	def update_credintials
		respond_to do |format|
			if @user.authenticate(params[:user][:old_password]) then
				if params[:user][:password] == params[:user][:confirm_password] then
					if @user.update(params.require(:user).permit(:password)) then
						format.html { redirect_to session_edit_path, success: 'User Password Updated !!!' }
                		format.json { render json: {"type" => "success", "text" => "User Password Updated !!!"} , status: :updated, location: @user }
						flash[:success] = 'User Password Updated !!!'
					else
						format.html { redirect_to session_edit_path, danger: @user.errors.full_messages }
               			format.json { render json: {"type" => "error", "text" => @user.errors}, status: :unprocessable_entity }
						flash[:danger] = @user.errors.full_messages
					end
				else
					format.html { redirect_to session_edit_path, danger: 'New Passwords didnt match !!!' }
               		format.json { render json: {"type" => "error", "text" => "New Passwords didnt match !!!"}, status: :unprocessable_entity }
					flash[:danger] = 'New Passwords didnt match !!!'
				end
			else
				format.html { redirect_to session_edit_path, danger: 'Wrong Password !!!' }
               	format.json { render json: {"type" => "error", "text" => "Wrong Password !!!"}, status: :unprocessable_entity }
				flash[:danger] = 'Wrong Password !!!'
			end
		end
	end

	def update_address
		respond_to do |format|
			@user.country = params[:user][:country]
			@user.town = params[:user][:town]
			if @user.authenticate(params[:user][:password]) then
				if @user.save then
					format.html { redirect_to session_edit_path, success: 'User Address Updated !!!' }
                	format.json { render json: {"type" => "success", "text" => "User Address Updated !!!"} , status: :updated, location: @user }
					flash[:success] = 'User Address Updated !!!'
				else 
					format.html { redirect_to session_edit_path, danger: @user.errors.full_messages }
               		format.json { render json: {"type" => "error", "text" => @user.errors}, status: :unprocessable_entity }
					flash[:danger] = @user.errors.full_messages
				end
			else
				format.html { redirect_to session_edit_path, danger: 'Wrong Password !!!' }
               	format.json { render json: {"type" => "error", "text" => "Wrong Password !!!"}, status: :unprocessable_entity }
				flash[:danger] = 'Wrong Password !!!'
			end
		end
	end

	def update_contact
		flash[:danger] = "Not Available !!!"
		redirect_to controller: 'session', action: 'edit'
	end

	def logout
		logout_user
		flash[:notice] = "User Logged Out !!!"
		redirect_to root_url
	end

	def destroy
	end

	def report_new
		if is_logged_in?
			@report = Report.new
			@ressource_id = params[:ressource_id]
			@ressource = params[:ressource]
			render layout: false
		else
			redirect_to new_user_path + "?layout=false"
		end
	end

	def report_create
		if is_logged_in?
			@report = Report.new(params[:report].permit(:ressource_id, :ressource, :about, :text))
			@report.user_id = session[:user_id]
			if @report.save then
				render json:{"type" => "success", "text" => "Report Submited Successfully !!!"}
			else
				render json:{"type" => "error", "text" => @report.errors.full_messages}
			end
		else
			render json:{"type" => "error", "text" => "Please, Login !!!"}
		end
	end

	private def set_data_items_counts
		items = Item.where(user_id: session[:user_id])
		@borrowed_count = 0
		
		items.each do |item|
			counts = item.borrow_item_user.count
			@borrowed_count += counts
		end

		@borrowing_count = BorrowItemUser.where(user_id: session[:user_id]).count
		@favourites_count = @user.item_favourite.all.count
		@requests_count = @user.item_request.all.count
	end

	private def get_borrow_item_data(item)
		data = Hash.new
		data["item"] = item
		data["count"] = item.borrow_item_user.count
		data["pending"] = item.borrow_item_user.where(status: @status[0]).count
		data["accepted"] = item.borrow_item_user.where(status: @status[1]).count
		data["rejected"] = item.borrow_item_user.where(status: @status[2]).count
		data["rendered"] = item.borrow_item_user.where(status: @status[3]).count
		data["returned"] = item.borrow_item_user.where(status: @status[4]).count
		data["failed"] =item.borrow_item_user.where(status: @status[5]).count
		
		return data
	end

	private def set_session
		if is_logged_in? then
			@status = Array["pending", "accepted", "rejected", "rendered", "returned", "succeeded", "failed"]
			@user = User.find_by(id: session[:user_id])
		else
			flash[:danger] = "Please, Login !!!"
			redirect_to root_url
		end
	end
    
end
