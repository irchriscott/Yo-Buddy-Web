class ListBorrowItem < ApplicationRecord
	
  	belongs_to :borrow_item_user

  	def item_code
		return "#{self.id}-#{self.borrow_item_user.item.created_at.to_i}-#{self.borrow_item_user.id + self.borrow_item_user.item.user.id}"
	end
end
