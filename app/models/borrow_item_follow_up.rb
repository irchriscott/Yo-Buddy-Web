class BorrowItemFollowUp < ApplicationRecord
  belongs_to :borrow_item_user
  belongs_to :admin
end
