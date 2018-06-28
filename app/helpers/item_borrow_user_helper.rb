module ItemBorrowUserHelper
	
	include UserHelper

	def check_borrows
		pers = Array["Hour", "Day", "Week", "Month", "Year"]
		now = Time.now
		BorrowItemUser.all.each do |borrow|
			from = borrow.from_date.localtime
			to = borrow.to_date.localtime
			if borrow.status == "pending" or borrow.status == "rejected" then
				if now > to then
					borrow.status = "failed"
					borrow.save
					save_message "failed", borrow
                    Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
                    Notification.create([{user_from_id: borrow.item.user.id, user_to_id: borrow.item.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
				end
			elsif borrow.status == "accepted" then
				received = borrow.borrow_item_admin.where(status: "received").last
				rendered = borrow.borrow_item_admin.where(status: "rendered").last
				if received != nil then
					if rendered == nil then
						if borrow.per == pers[0] then
							if borrow.numbers < 3 then
								if now > check_date(received.created_at.localtime, 0, 0, 30) then
									borrow.status = "failed"
									borrow.save
									save_message "failed", borrow
                                    Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
                                    Notification.create([{user_from_id: borrow.item.user.id, user_to_id: borrow.item.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
								end
							else
								if now > check_date(received.created_at.localtime, 0, 1, 0) then
									borrow.status = "failed"
									borrow.save
									save_message "failed", borrow
                                    Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
								    Notification.create([{user_from_id: borrow.item.user.id, user_to_id: borrow.item.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
                                end
							end
						elsif borrow.per == pers[1] then
							if borrow.numbers < 3 then
								if now > check_date(received.created_at.localtime, 0, 12, 0) then
									borrow.status = "failed"
									borrow.save
									save_message "failed", borrow
                                    Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
								    Notification.create([{user_from_id: borrow.item.user.id, user_to_id: borrow.item.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
                                end
							else
								if now > check_date(received.created_at.localtime, 1, 0, 0) then
									borrow.status = "failed"
									borrow.save
									save_message "failed", borrow
                                    Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
								    Notification.create([{user_from_id: borrow.item.user.id, user_to_id: borrow.item.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
                                end
							end
						elsif borrow.per == pers[2] then
							if now > check_date(received.created_at.localtime, 2, 0, 0) then
								borrow.status = "failed"
								borrow.save
								save_message "failed", borrow
                                Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
                                Notification.create([{user_from_id: borrow.item.user.id, user_to_id: borrow.item.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
                            end
						else
							if now > check_date(received.created_at.localtime, 3, 0, 0) then
								borrow.status = "failed"
								borrow.save
								save_message "failed", borrow
                                Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
                                Notification.create([{user_from_id: borrow.item.user.id, user_to_id: borrow.item.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
							end
						end
					end
				end
			end
		end
	end

    def check_date(date, days, hours, minutes)
    	return date + (days.to_i * 24 * 60 * 60) + (hours.to_i * 60 * 60) + (minutes.to_i * 60)
    end

    def check_session
        if !is_logged_in?
            flash[:danger] = "Loggin Required !!!"
            redirect_to new_user_path + "?layout=false"
        end
    end

    def set_item_data

        @categories = Category.all
        @subcategories = Subcategory.all

        @currencies = Array.new

        @currencies.append({"currency" => "UGX", "name" => "Uganda Shilling"})
        @currencies.append({"currency" => "FRC", "name" => "Franc Congolais"})
        @currencies.append({"currency" => "USD", "name" => "United State Dollars"})

        @per = Array["Hour", "Day", "Week", "Month", "Year"]

        @item = Item.find(params[:item_id])

        @status = Array["pending", "accepted", "rejected", "rendered", "returned", "succeeded", "failed"]
    end

    def check_owner_borrow
        borrow = @item.borrow_item_user.find(params[:id])
        if borrow.item.user.id != session[:user_id] and borrow.user.id != session[:user_id] then
            flash[:danger] = "You are not the Owner !!!"
            redirect_to session_items_path
        end
    end

    def set_time_end(borrow, from_time)

        per = borrow[:per]
        additional = 0

        case per
            when @per[0] then
                additional = (borrow[:numbers].to_i * 60 * 60) + (60 * 60)
            when @per[1] then
                additional = (borrow[:numbers].to_i * 24 * 60 * 60) - (1 * 60 * 60)
            when @per[2] then
                additional = (borrow[:numbers].to_i * 7 * 24 * 60 * 60) - (1 * 60 * 60)
            when @per[3] then
                additional = (borrow[:numbers].to_i * 30 * 24 * 60 * 60) + (1 * 24 * 60 * 60)
            when @per[4] then
                additional = (borrow[:numbers].to_i * 365 * 24 * 60 * 60) + (3 * 24 * 60 * 60)
            else
                additional = 0
        end
        
        return from_time + additional
    end

    def check_from_date(borrow)

        from_date = borrow[:from_date]
        from_time = Time.parse(from_date)
        now = Time.now
        date = from_time.to_date

        if borrow[:per] == @per[0] then
            if from_time > now + (1 * 60 * 60) then
                min = from_time.min
                if min < 15 then
                    return to_datetime(date, from_time.hour, 0)
                elsif min >= 15 and min < 45 then
                    return to_datetime(date, from_time.hour, 30)
                elsif min >= 45 then
                    return to_datetime(date, from_time.hour + 1, 0)
                end
            else
                return 2
            end
        else
            if date >= now.to_date + 1 then
                return to_datetime(date, 9, 0)
            else
                return 1
            end 
        end
    end

    def to_datetime(date, hour, min)
        return Time.local(date.year, date.month, date.day, hour, min)
    end

    def set_data_items_counts
        items = Item.where(user_id: session[:user_id])
        @borrowed_count = 0
        
        items.each do |item|
            counts = item.borrow_item_user.count
            @borrowed_count += counts
        end
        @borrowing_count = BorrowItemUser.where(user_id: session[:user_id]).count
        @favourites_count = @item.user.item_favourite.all.count
        @requests_count = @item.user.item_request.all.count
    end

    def check_counts(from_date, to_date)
        @borrow_check = @item.borrow_item_user.all.order(from_date: :asc)
        counts = 0
        @borrow_check.each{ |b|
            if b.to_date >= from_date and to_date >= b.from_date  then
                if b.status == @status[1] or b.status == @status[3] then
                    counts += b.count 
                end
            end
        }
        return counts
    end

    def save_message(status, borrow)
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
