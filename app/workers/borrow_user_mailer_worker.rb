class BorrowUserMailerWorker

  	include Sidekiq::Worker

  	def perform(*args)
		check_borrows
  	end

  	private def check_borrows
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

    private def check_date(date, days, hours, minutes)
    	return date + (days.to_i * 24 * 60 * 60) + (hours.to_i * 60 * 60) + (minutes.to_i * 60)
    end
    private def save_message(status, borrow)
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
