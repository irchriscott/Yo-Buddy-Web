class AdminItem < ApplicationRecord

  belongs_to :item

  def borrow
  	if self.borrow_id != 0 or self.borrow_id.to_i > 0 then
  		return BorrowItemUser.find(self.borrow_id)
  	else
  		return nil
  	end
  end

end
