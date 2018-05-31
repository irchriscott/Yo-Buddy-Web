class BorrowMessage < ApplicationRecord
	
	belongs_to :borrow_item_user
	has_many :borrow_message_image

	def sender
		return User.find(self.sender_id) if self.sender_id != 0
	end
	
	def receiver
		return User.find(self.receiver_id) if self.receiver_id != 0
	end

	def admin_message
		if self.receiver_id == 0 and self.sender_id == 0 then
			if self.message == "new" then
				return self.message
			elsif self.message == "data" then
				return "Borrow Item Updated"
			else
				return "Borrow Status Updated To #{self.message.capitalize}"
			end	
		end
	end

	def images
		if self.has_images? then
			return self.borrow_message_image
		end
	end
end
