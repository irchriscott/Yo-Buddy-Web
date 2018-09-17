class AdminUserController < ApplicationController

	include AdminUserHelper
	include AdminHelper
	include ItemBorrowUserHelper
	include ApplicationHelper

	before_action :check_admin_user_session, except: [:signin, :index, :reset_password, :send_reset_password_mail, :reset_password_form, :reset_change_password, :set_activation, :activate_key, :logout]
	before_action :set_data

	@@login_attempts = 0

	def index
		if is_admin_user_logged_in?
			redirect_to admin_u_path
		end
	end

	def signin

		admin = AdminUser.where(email: params[:admin_user][:email]).first

		if @@login_attempts < 5 then
			if admin then
				if admin.authenticate(params[:admin_user][:password]) then
					login_admin_user admin
					flash[:success] = "Admin User Logged In Successfully !!!"
					@@login_attempts = 0
					redirect_to admin_u_path
				else
					flash[:danger] = "Incorrect Password !!!"
					@@login_attempts += 1
					redirect_to admin_u_index_path
				end
			else
				flash[:danger] = "Incorrect Email or Username !!!"
				@@login_attempts += 1
				redirect_to admin_u_index_path
			end
		else
			flash[:danger] = "Try Later !!!"
			redirect_to root_path
		end
	end

	def logout
		logout_admin_user
		flash[:success] = "Admin User Logged Out Successfully !!!"
		redirect_to admin_u_index_path
	end

	def home
		@items = session_admin_user.user.item.all.order(created_at: :desc).limit(10)
		@borrows = BorrowItemUser.joins("INNER JOIN items ON borrow_item_users.item_id = items.id INNER JOIN users ON items.user_id = users.id").where("users.id = ?", session_admin_user.user.id).order(created_at: :desc).limit(10)
		
		@rendered = to_be_rendered(session_admin_user.user.id, Time.now.to_date).count
		@returned = to_be_returned(session_admin_user.user.id, Time.now.to_date).length
		
		@late_render = late_to_be_rendered(session_admin_user.user.id, Time.now.to_date).length
		@late_receive = late_to_be_received(session_admin_user.user.id, Time.now.to_date).length
		@late_return = late_to_be_returned(session_admin_user.user.id, Time.now).length
	end

	def items
		@items = AdminItem.joins("INNER JOIN items ON admin_items.item_id = items.id INNER JOIN users ON items.user_id = users.id").where("users.id = ? ", session_admin_user.user.id).order(created_at: :desc)
	end

	def borrows
		@borrows = BorrowItemUser.joins("INNER JOIN items ON borrow_item_users.item_id = items.id INNER JOIN users ON items.user_id = users.id").where("users.id = ?", session_admin_user.user.id).order(created_at: :desc)
	end

	def item
		@item = Item.find(params[:id])
		@borrows = @item.borrow_item_user.all.order(created_at: :desc)
		if @item.user.id != session_admin_user.user.id then
			flash[:danger] = "You Are Not The Owner !!!"
			redirect_to admin_u_index_path
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

		if @item.user.id != session_admin_user.user.id then
			flash[:danger] = "You Are Not The Owner !!!"
			redirect_to admin_u_index_path
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
		redirect_to admin_u_borrow_path(@borrow.item.uuid, @borrow.item, @borrow)
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

	def scan_borrow
		render layout: false
	end

	def scan_borrow_post
		borrow = check_scan_data params[:borrow_scan][:data]
		if borrow != 0 then
			if borrow.item.user.id == session_admin_user.user.id then
				render json: {"type" => "success", "text" => admin_u_borrow_path(borrow.item.uuid, borrow.item, borrow)}
			else
				render json: {"type" => "error", "text" => "You Are Not The Owner !!!"}
			end
		else
			render json: {"type" => "error", "text" => "Borrow Not Found !!!"}
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
							item.is_available = false
							item.save
							save_message(@status[4], @borrow)
						elsif params[:borrow_item_admin][:status] == @borrow_admin_status[4] then
							item.is_available = true
							item.save
							save_message(@status[5], @borrow)
						elsif params[:borrow_item_admin][:status] == @borrow_admin_status[5] then
							item.is_available = true
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
			redirect_to admin_u_borrow_path(@borrow.item.uuid, @borrow.item, @borrow) + "?status=#{params[:borrow_item_admin][:status]}&state=#{state}"
		else
			flash[:danger] = "Only allowed if status is Accepted"
			redirect_to admin_u_borrow_path(@borrow.item.uuid, @borrow.item, @borrow)
		end
	end

	def borrow_act_received
		@borrow = BorrowItemUser.find(params[:id])
		@act = borrow_received_act(@borrow, session_admin_user.user.name)
		render layout: false
	end

	def borrow_act_rendered
		@borrow = BorrowItemUser.find(params[:id])
		@act = borrow_rendered_act(@borrow, session_admin_user.user.name)
		render layout: false
	end

	def new_borrow
		@item = Item.find(params[:item_id])

		@currencies = Array.new
        @currencies.append({"currency" => "UGX", "name" => "Uganda Shilling"})
        @currencies.append({"currency" => "FRC", "name" => "Franc Congolais"})
        @currencies.append({"currency" => "USD", "name" => "United State Dollars"})

        @per = Array["Hour", "Day", "Week", "Month", "Year"]
        @active = true

		render layout: false
	end

	def create_borrow

		@borrow = BorrowItemUser.new(borrow_params)
        @borrow.user_id = params[:user_id]
        @borrow.status = @status[0]
        @borrow.last_update_user_id = session_admin_user.user.id
        @borrow.uuid = generate_uuid("", 24)

        item = Item.find(params[:item_borrow][:item_id])
        from_date = check_from_date(params[:item_borrow])

        if @active == true then

            if from_date == 2 then
            	flash[:danger] = "Time Already Passed !!!"
            	redirect_to admin_u_item_path(item.user.username, item.uuid, item)
            elsif from_date == 1 then
            	flash[:danger] = "Date Should not be Less Than Tomorrow !!!"
            	redirect_to admin_u_item_path(item.user.username, item.uuid, item)
            else
                to_date = set_time_end(params[:item_borrow], from_date)
                quant = params[:item_borrow][:count].to_i
                rests = @item.count - check_counts(from_date, to_date)
                
                if rests < 0 then
                    rests = 0
                end

                if rests >= quant and @item.count >= quant then
                    @borrow.from_date = from_date
                    @borrow.to_date = to_date

                    if item.user.id != session[:user_id] then
                        if @borrow.save then
                            save_message("new", @borrow)
                            Notification.create([{user_from_id: session_admin_user.user.id, user_to_id: params[:user_id], ressource: "item_borrow_else", ressource_id: item.id, is_read: false}])

                            flash[:success] = "Item Borrow Request Sent !!!"
                            redirect_to admin_u_item_path(item.user.username, item.uuid, item)
                        else
                        	flash[:danger] = @borrow.errors.full_messages
                        	redirect_to admin_u_item_path(item.user.username, item.uuid, item)
                        end
                    else
                    	flash[:danger] = "Cant Borrow Your Own Item !!!"
                    	redirect_to admin_u_item_path(item.user.username, item.uuid, item)
                    end
                else
                    flash[:danger] = "Available Items On That Date is #{rests}"
                    redirect_to admin_u_item_path(item.user.username, item.uuid, item)
                end
            end
        else
            flash[:danger] = "Your Private Account Is Not Active !!!"
            redirect_to admin_u_item_path(item.user.username, item.uuid, item)
        end
	end

	def search_user
		@users = User.where("name LIKE ? OR username LIKE ?", "%#{params[:query]}%", "%#{params[:query]}%").order(created_at: :desc)
	end

	def set_activation
		if !is_admin_user_logged_in?
			flash[:danger] = "Please, Log In !!!";
			redirect_to admin_u_index_path
		else
			@activation = session_admin_user.admin_user_activation
			@items = get_sum_items(session_admin_user.user.id)
			@package = get_preferable_package(@items)
		end
	end

	def activate_key
		if !is_admin_user_logged_in?
			flash[:danger] = "Please, Log In !!!";
			redirect_to admin_u_index_path
		end
		full_key = "#{params[:activate_key][:key_1]}#{params[:activate_key][:key_2]}#{params[:activate_key][:key_3]}#{params[:activate_key][:key_4]}".upcase
		
		key = YbKey.find_by(key: full_key)

		if key != nil then
			if key.status == "on" then
				if key.remaining.to_i >= 1 then
					key_use = AdminUserActivation.where(yb_key_id: key.id).where(is_active: true).count
					if key_use  == 0 then
						items = get_sum_items(session_admin_user.user.id)
						if (items.to_i == 0 and key.yb_package.package == "trial") or items.to_i <= key.yb_package.items.to_i or key.yb_package.package == "altimate" then
							
							session_admin_user.admin_user_activation.is_active = true
							session_admin_user.admin_user_activation.yb_key_id = key.id
							session_admin_user.admin_user_activation.save

							key.is_active = true
							key.activated_date = Time.now
							key.save

							usage = YbKeyUsage.new
							usage.yb_key_id = key.id
							usage.admin_user_id = session_admin_user.id
							usage.save

							flash[:success] = "Key And Account Activated !!!"
						else
							flash[:danger] = "The Key Didnt Match Your Package !!!"
						end
					else
						flash[:danger] = "This Key Is Being Used !!!"
					end
				else
					flash[:danger] = "Remaining Period Of This Key Is #{key.remaining} !!!"
				end
			else
				flash[:danger] = "Key Status is #{key.status.capitalize!} !!!"
			end
		else
			flash[:danger] = "Unknown Key !!!"
		end
		redirect_to admin_u_activation_path
	end

	def reset_password
    end

    def send_reset_password_mail
    	respond_to do |format|
            user = AdminUser.find_by(email: params[:email][:email])
            if user != nil then

                token = SecureRandom.urlsafe_base64(user.user.name.length)
                rsp_check = ResetPassword.where(resource: "admin_user", resource_id: user.id).first

                if rsp_check != nil then
                    rsp_check.token = token
                    rsp_check.is_active = true
                    rsp_check.expiry_date = get_expiry_date(1)
                    rsp_check.count += 1
                    rsp_check.save
                else
                    ResetPassword.create([{resource: "admin_user", resource_id: user.id, email: params[:email][:email], token: token, expiry_date: get_expiry_date(1), is_active: true, count: 1 }])
                end

                ResetPasswordMailer.send_link(params[:email][:email], admin_u_rp_link_url(token)).deliver_now

                flash[:success] = "Link Sent To The Email Address !!!";
                format.html { redirect_to admin_u_index_path }
                format.json { render json: { "type" => "success", "text" => "Link Sent To The Email Address !!!" } }
            else
                flash[:danger] = "Unknown Email Address !!!";
                format.html { redirect_to admin_u_reset_password_path }
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
                redirect_to admin_u_reset_password_path
            end
        else
            flash[:error] = "Unknown Token !!!"
            redirect_to admin_u_reset_password_path
        end
    end

    def reset_change_password
    	rsp = ResetPassword.find_by(token: params[:new_pswd][:rsp_token])
    	if params[:new_pswd][:password] == params[:new_pswd][:conf_password] then
    		
    		admin = AdminUser.find(rsp.resource_id)
    		admin.password = params[:new_pswd][:password]
    		admin.save

    		rsp.is_active = false
    		rsp.save

    		flash[:success] = "Password Changed !!!"
    		redirect_to admin_u_index_path
    	else
    		flash[:danger] = "Password Didnt Match !!!"
    		redirect_to admin_u_rp_link_path(rsp.token)
    	end
    end

    private def borrow_params
        params.require(:item_borrow).permit(:item_id, :price, :currency, :per, :numbers, :conditions, :count)
    end
end
