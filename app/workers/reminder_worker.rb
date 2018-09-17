class ReminderWorker

	include Sidekiq::Worker

	def perform(*args)
	    check_borrow
	end

	private def check_borrow

		pers = Array["Hour", "Day", "Week", "Month", "Year"]
		now = Time.now

		BorrowItemUser.all.each do |borrow|

			from = borrow.from_date.localtime
			to = borrow.to_date.localtime

			time = from.to_time.to_i - now.to_time.to_i
			dead = now.to_time.to_i - to.to_time.to_i

			if borrow.status == "accepted" or borrow.status == "rendered" and time <= (12 * 60 * 60) then

				received = borrow.borrow_item_admin.where(status: "received").last
				rendered = borrow.borrow_item_admin.where(status: "rendered").last

				if received == nil then
					if borrow.per == pers[0] and borrow.numbers >= 12 then
						ReminderMailer.bring_item(borrow).deliver_now
						Notification.create([{user_from_id: borrow.item.user.id, user_to_id: borrow.item.user.id , ressource: "reminder_bring_item", ressource_id: borrow.id, is_read: false}])
					else
						ReminderMailer.bring_item(borrow).deliver_now
						Notification.create([{user_from_id: borrow.item.user.id, user_to_id: borrow.item.user.id , ressource: "reminder_bring_item", ressource_id: borrow.id, is_read: false}])
					end
				elsif received != nil && rendered == nil then
					if borrow.per == pers[0] and borrow.numbers >= 12 then
						ReminderMailer.pick_item(borrow).deliver_now
						Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "reminder_pick_item", ressource_id: borrow.id, is_read: false}])
					else
						ReminderMailer.pick_item(borrow).deliver_now
						Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "reminder_pick_item", ressource_id: borrow.id, is_read: false}])
					end
				elsif received != nil && rendered != nil && dead <= (12 * 60 * 60) then
					ReminderMailer.return_item(borrow).deliver_now
					Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "reminder_return_item", ressource_id: borrow.id, is_read: false}])
				end
			end

		end
	end
end
