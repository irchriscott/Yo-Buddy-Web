class BorrowUpdateWorker
	
  	include Sidekiq::Worker

  	def perform(*args)
    	pers = Array["Hour", "Day", "Week", "Month", "Year"]
		now = Time.now
		BorrowItemUser.all.each do |borrow|
			from = borrow.from_date.localtime
			to = borrow.to_date.localtime
			if borrow.status == "pending" or borrow.status == "rejected" then
				if now > from and now < to then
					Notification.create([{user_from_id: borrow.user.id, user_to_id: borrow.user.id , ressource: "update_borrow_required", ressource_id: borrow.id, is_read: false}])
                    Notification.create([{user_from_id: borrow.item.user.id, user_to_id: borrow.item.user.id , ressource: "update_borrow_required", ressource_id: borrow.id, is_read: false}])
                    BorrowUserMailer.with(borrow: borrow).update_required(borrow.user.email).deliver_now
                    BorrowUserMailer.with(borrow: borrow).update_required(borrow.item.user.email).deliver_now
				end
			end
		end
  	end
end
