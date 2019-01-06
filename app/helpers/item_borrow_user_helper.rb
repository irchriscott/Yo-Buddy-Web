module ItemBorrowUserHelper
	
	include UserHelper
    include ApplicationHelper
    include ActionView::Helpers::OutputSafetyHelper

	def check_borrows
		pers = ApplicationHelper::PERS
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
                    BorrowUserMailer.with(borrow: borrow).status(borrow.user.email).deliver_now
                    BorrowUserMailer.with(borrow: borrow).status(borrow.item.user.email).deliver_now
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
                                    BorrowUserMailer.with(borrow: borrow).failed(borrow.user.email).deliver_now
                                    BorrowUserMailer.with(borrow: borrow).failed(borrow.item.user.email).deliver_now
								end
							else
								if now > check_date(received.created_at.localtime, 0, 1, 0) then
									borrow.status = "failed"
									borrow.save
									save_message "failed", borrow
                                    Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
								    Notification.create([{user_from_id: borrow.item.user.id, user_to_id: borrow.item.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
                                    BorrowUserMailer.with(borrow: borrow).failed(borrow.user.email).deliver_now
                                    BorrowUserMailer.with(borrow: borrow).failed(borrow.item.user.email).deliver_now
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
                                    BorrowUserMailer.with(borrow: borrow).failed(borrow.user.email).deliver_now
                                    BorrowUserMailer.with(borrow: borrow).failed(borrow.item.user.email).deliver_now
                                end
							else
								if now > check_date(received.created_at.localtime, 1, 0, 0) then
									borrow.status = "failed"
									borrow.save
									save_message "failed", borrow
                                    Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
								    Notification.create([{user_from_id: borrow.item.user.id, user_to_id: borrow.item.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
                                    BorrowUserMailer.with(borrow: borrow).failed(borrow.user.email).deliver_now
                                    BorrowUserMailer.with(borrow: borrow).failed(borrow.item.user.email).deliver_now
                                end
							end
						elsif borrow.per == pers[2] then
							if now > check_date(received.created_at.localtime, 2, 0, 0) then
								borrow.status = "failed"
								borrow.save
								save_message "failed", borrow
                                Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
                                Notification.create([{user_from_id: borrow.item.user.id, user_to_id: borrow.item.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
                                BorrowUserMailer.with(borrow: borrow).failed(borrow.user.email).deliver_now
                                BorrowUserMailer.with(borrow: borrow).failed(borrow.item.user.email).deliver_now
                            end
						else
							if now > check_date(received.created_at.localtime, 3, 0, 0) then
								borrow.status = "failed"
								borrow.save
								save_message "failed", borrow
                                Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
                                Notification.create([{user_from_id: borrow.item.user.id, user_to_id: borrow.item.user.id , ressource: "self_update_item_borrow_failed", ressource_id: borrow.id, is_read: false}])
                                BorrowUserMailer.with(borrow: borrow).failed(borrow.user.email).deliver_now
                                BorrowUserMailer.with(borrow: borrow).failed(borrow.item.user.email).deliver_now
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

        @currencies = ApplicationHelper::CURRENCIES

        @per = ApplicationHelper::PERS

        @item = Item.find(params[:item_id])

        @status = ApplicationHelper::BORROW_STATUSES
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
        
        if !Array["new", "data"].include?(status) then
            borrow.status = status
            borrow.save
        end

        message = BorrowMessage.new
        message.borrow_item_user_id = borrow.id
        message.sender_id = 0
        message.receiver_id = 0
        message.message = status
        message.status = "unread"
        message.has_images = false
        message.is_deleted = false
        message.save
    end

    def to_be_received(*args)
        return (args.length > 1) ? BorrowItemUser.joins("INNER JOIN items ON borrow_item_users.item_id = items.id INNER JOIN users ON items.user_id = users.id").where("users.id = ?", args[0]).where(status: "accepted").where("DATE(from_date) = ?", args[2]).order(created_at: :desc) : BorrowItemUser.joins("INNER JOIN items ON borrow_item_users.item_id = items.id INNER JOIN users ON items.user_id = users.id").where("users.is_private = ?", false).where(status: "accepted").where("DATE(from_date) = ?", Time.now.to_date).order(created_at: :desc)
    end

    def to_be_rendered(*args)
        borrows = Array.new
        BorrowItemUser.all.each do |borrow|
            if borrow.was_received && borrow.from_date.localtime.to_date == args[0] then
                if args.length == 1 then
                    borrows.push(borrow) if !borrow.item.user.is_private?
                else
                    borrows.push(borrow) if borrow.item.user.id == args[1]
                end 
            end
        end
        return borrows
    end

    def to_be_returned(*args)
        borrows = Array.new
        BorrowItemUser.all.each do |borrow|
            if borrow.was_rendered && borrow.to_date.localtime.to_date == args[0] then
                if args.length == 1 then
                    borrows.push(borrow) if !borrow.item.user.is_private?
                else
                    borrows.push(borrow) if borrow.item.user.id == args[1]
                end 
            end
        end
        return borrows
    end

    def late_to_be_received(*args)
        borrows = Array.new
        BorrowItemUser.all.each do |borrow|
            if !borrow.was_received && borrow.from_date.localtime.to_date < args[0] then
                if args.length == 1 then
                    borrows.push(borrow) if !borrow.item.user.is_private?
                else
                    borrows.push(borrow) if borrow.item.user.id == args[1]
                end 
            end
        end
        return borrows
    end

    def late_to_be_rendered(*args)
        borrows = Array.new
        BorrowItemUser.all.each do |borrow|
            if borrow.was_received && !borrow.was_rendered && borrow.from_date.localtime.to_date < args[0] then
                if args.length == 1 then
                    borrows.push(borrow) if !borrow.item.user.is_private?
                else
                    borrows.push(borrow) if borrow.item.user.id == args[1]
                end 
            end
        end
        return borrows
    end

    def late_to_be_returned(*args)
        borrows = Array.new
        BorrowItemUser.all.each do |borrow|
            if borrow.was_received && borrow.was_rendered && !borrow.was_returned && check_date(borrow.to_date.localtime, 0, 4, 0) < args[0] then
                if args.length == 1 then
                    borrows.push(borrow) if !borrow.item.user.is_private?
                else
                    borrows.push(borrow) if borrow.item.user.id == args[1]
                end 
            end
        end
        return borrows
    end

    def borrow_data_template(borrow, qr_borrower, qr_owner, time)
        return "<!DOCTYPE html>
                <html>
                    <head>
                        <title></title>
                        <style type='text/css'>
                            table {
                              border-width: 0;
                              border-style: none;
                              border-color: #0000ff;
                              border-collapse: collapse;
                            }

                            td {
                              border-left: solid 10px #000;
                              padding: 0; 
                              margin: 0; 
                              width: 0px; 
                              height: 10px; 
                            }

                            td.black { border-color: #000; }
                            td.white { border-color: #fff; }
                            .yb-description{display: none !important;}
                        </style>
                    </head>
                    <body>
                        <section id='yb-borrow-code-document' style='display: none !important;'>
                            <div style='font-family:Avenir, Century Gothic, sans-serif; font-size:16px; padding:15px; position:relative; color: #333 !important;'>
                                <div style='margin:auto; margin-bottom: 10px; border-bottom:2px solid #333; text-align:center;'>
                                    <h3 style='font-size:26px;'>YO BUDDY</h3>
                                </div>
                                <div style='position: absolute; right:0; margin-top:-10px; margin-right:15px;'>
                                    <p>#{session_user.town}, #{time.localtime.strftime("%d %B %Y at %H:%M")}</p>
                                </div>
                                <div style='text-align:center; margin-top:55px; margin-bottom:35px;'>
                                    <h4 style='font-size:20px;'>BORROW DESCRIPTION</h4>
                                </div>
                                <p><strong>ID : </strong>#{borrow.code}</p>
                                <p><strong>Owner : </strong>#{borrow.item.user.name}</p>
                                <p><strong>Borrower : </strong>#{borrow.user.name}</p>
                                <p><strong>Item : </strong>#{@borrow.item.name}</p>
                                <p><strong>Category : </strong>#{borrow.item.category.name} - #{borrow.item.subcategory.name}</p>
                                <p><strong>Single Price : </strong>#{borrow.price} #{borrow.currency} / #{borrow.per}</p>
                                <p><strong>Number : </strong>#{borrow.updated_numbers} #{borrow.per}s</p>
                                <p><strong>Quantity : </strong>#{borrow.count} Items</p>
                                <p><strong>Total : </strong>#{borrow.borrow_total} #{borrow.currency}</p>
                                <p><strong>From : </strong> #{borrow.from_date.localtime.strftime("%a %d %b, %Y at %H:%M")}</p>
                                <p><strong>To : </strong> #{borrow.to_date.localtime.strftime("%a %d %b, %Y at %H:%M")}</p>
                                <p><strong>Status : </strong> #{borrow.status}</p>
                                <p><strong>Request Date : </strong> #{borrow.created_at.localtime.strftime('%Y-%m-%d %H:%M:%S')}</p>
                                <div style='margin:30px 0;' data-id='#{borrow.code}'>
                                    #{get_qr_user(borrow, qr_borrower, qr_owner)}
                                </div>
                            </div>
                        </section>
                    </body>
                </html>"
    end

    def get_qr_user(borrow, qr_borrower, qr_owner)
        return (session_user.id == borrow.user.id) ? (raw qr_borrower.as_html) : (raw qr_owner.as_html)
    end
end
