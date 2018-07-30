module AdminHelper

	TRIAL_NUM_DAYS = 30

	def login_admin(admin)
		session[:admin] = admin.id
	end

	def session_admin
		@admin ||= Admin.find_by(id: session[:admin])
	end

	def is_admin_logged_in?
		!session_admin.nil?
	end

	def logout_admin
		session.delete(:admin)
		@admin = nil
	end

	def admin_id
		session[:admin]
	end

	def borrow_received_act(borrow, user="Yo Buddy")
		now = Time.new
		return "
			<div style='font-family:Avenir, Century Gothic, sans-serif; font-size:17px; padding:15px; position:relative;'>
				<div style='margin:auto; margin-bottom: 10px; border-bottom:2px solid #333; text-align:center;'>
					<h3 style='font-size:26px;'>YO BUDDY</h3>
				</div>
				<div style='position: absolute; right:0; margin-top:-10px; margin-right:15px;'>
					<p>Kampala, #{now.localtime.strftime("%d %B %Y at %H:%M")}</p>
				</div>
				<div style='text-align:center; margin-top:55px; margin-bottom:35px;'>
					<h4 style='font-size:20px;'>ACT OF BORROW - RECEPTION</h4>
				</div>
				<div style='text-align:justify; line-height:25px;'>
					<p>
						I, <strong>#{user}</strong> Admin of YO BUDDY, have received 
						<strong>#{borrow.item.name}</strong> from <strong> #{borrow.item.user.name}</strong> of borrow No <strong>#{borrow.code}</strong> to give to 
						<strong>#{borrow.user.name}</strong> who will be in posession of the item from
						<strong>#{borrow.from_date.localtime.strftime("%A, %d %B %Y at %H:%M")}</strong> to <strong>#{borrow.to_date.localtime.strftime("%A, %d %B %Y at %H:%M")}</strong> for
						<strong>#{borrow.borrow_total} #{borrow.currency}</strong>.
						For this concern, I have agreed on terms and conditions of YO BUDDY about borrowing item and orthed
						to respected them but also I have agreed on terms and conditions about this borrow here down : 	
					</p>
					<div class='display:block; position:relative;'>
						#{borrow.conditions}
					</div>
				</div>
				<div style='display:block; position:relative; margin-top:35px;'>
					<div style='float:left;'>
						<p>Owner</p>
						<div style='height:10px;'></div>
						<p><strong>#{borrow.item.user.name}</strong></p>
					</div>
					<div style='float:left; margin-left:70px;'>
						<p>Yo Buddy Admin</p>
						<div style='height:10px;'></div>
						<p><strong>#{user}</strong></p>
					</div>
				</div>
			</div>
		"
	end

	def borrow_rendered_act(borrow, user="Yo Buddy")
		now = Time.new
		return "
			<div style='font-family:Avenir, Century Gothic, sans-serif; font-size:17px; padding:15px; position:relative;'>
				<div style='margin:auto; margin-bottom: 10px; border-bottom:2px solid #333; text-align:center;'>
					<h3 style='font-size:26px;'>YO BUDDY</h3>
				</div>
				<div style='position: absolute; right:0; margin-top:-10px; margin-right:15px;'>
					<p>Kampala, #{now.localtime.strftime("%d %B %Y at %H:%M")}</p>
				</div>
				<div style='text-align:center; margin-top:55px; margin-bottom:35px;'>
					<h4 style='font-size:20px;'>ACT OF BORROW - RENDERING</h4>
				</div>
				<div style='text-align:justify; line-height:25px;'>
					<p>
						I, <strong>#{borrow.user.name}</strong> have borrowed a
						<strong>#{borrow.item.name}</strong> from <strong> #{borrow.item.user.name}</strong> of borrow No <strong>#{borrow.code}</strong> from 
						<strong>#{borrow.from_date.localtime.strftime("%A, %d %B %Y at %H:%M")}</strong> to <strong>#{borrow.to_date.localtime.strftime("%A, %d %B %Y at %H:%M")}</strong> for
						<strong>#{borrow.borrow_total} #{borrow.currency}</strong>.
						For this concern, I have agreed on terms and conditions of YO BUDDY about borrowing item and orthed
						to respected them but also I have agreed on terms and conditions about this borrow here down : 	
					</p>
					<div class='display:block; position:relative;'>
						#{borrow.conditions}
					</div>
				</div>
				<div style='display:block; position:relative; margin-top:35px;'>
					<div style='float:left;'>
						<p>Borrower</p>
						<div style='height:10px;'></div>
						<p><strong>#{borrow.user.name}</strong></p>
					</div>
					<div style='float:left; margin-left:70px;'>
						<p>Yo Buddy Admin</p>
						<div style='height:10px;'></div>
						<p><strong>#{user}</strong></p>
					</div>
				</div>
			</div>
		"
	end

	def get_borrow(n)
		statuses = Array["accepted", "rendered", "returned", "succeeded"]
		BorrowItemUser.all.each{ |borrow|
			if statuses.include?(borrow.status) then
				code = n.to_i
				_code = code - borrow.id
				id = code - _code
				if code == borrow.code and _code == borrow._code and id == borrow.id  then
					return borrow
				end
			end
		}
		return nil
	end

	def check_scan_data(data)
		datas = data.split("-")
		user = User.where(username: datas[2]).first

		puts datas.length
		
		if datas.length == 4 then
			if user then
				borrow = get_borrow(datas[0])
				if borrow != nil then
					if datas[1] == "owner" then
						if borrow.item.user.id == user.id then
							return borrow
						else
							return 0
						end 
					elsif datas[1] == "borrower" then
						if borrow.user.id == user.id then
							return borrow
						else
							return 0
						end
					else
						return 0
					end
				else
					return 0
				end
			else
				return 0
			end
		else
			return 0
		end
	end

	def check_item_borrow(code)
		data = code.split("-")
		if data.length == 5 then
			item = ListBorrowItem.find(data[0].to_i)
			if item then
				user_id = data[2].to_i - item.borrow_item_user.id
				user = User.find(user_id)
				if user then
					if user.username == data[3].to_s then
						message = item.borrow_item_user.borrow_item_admin.all.last
						if message != nil then
							if message.status == "rendered" then
								return item
							else
								return 1
							end
						else
							return 0
						end
					else
						return 0
					end
				else
					return 0
				end
			else
				return 0
			end
		else
			return 0
		end
	end

	def set_data
		@order_by = Array[{"id" => 1, "text" => "ID"}, {"id" => 2, "text" => "Name"}, {"id" => 3, "text" => "Date"}]
		@order = Array[{"id" => "asc", "text" => "Ascending"}, {"id" => "desc", "text" => "Descending"}]
		@borrow_admin_status = Array["received", "rendered", "returned", "finnished", "succeeded", "failed"]
		@item_states = Array["excellent", "very good", "good", "not bad", "bad" , "very bad"]
		@privileges = Array["all", "admins", "borrows", "items"]
		@status = Array["pending", "accepted", "rejected", "rendered", "returned", "succeeded", "failed"]
		@categories = Category.all.order(name: :asc)
		@subcategories = Subcategory.all.order(name: :asc)
		@active = true
	end

	def check_admin_session
		if !is_admin_logged_in? then
			flash[:danger] = "Explusive For Administration Only !!!";
			redirect_to admin_index_path
		end
	end

	def save_message(status, borrow)
		borrow.status = status
        borrow.save
        
        message = BorrowMessage.new
        message.borrow_item_user_id = borrow.id
        message.sender_id = 0
        message.receiver_id = 0
        message.message = status
        message.status = "unread"
        message.is_deleted = false
        message.save
    end
	
end
