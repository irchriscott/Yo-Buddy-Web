class BorrowItemAdmin < ApplicationRecord
  belongs_to :borrow_item_user
  belongs_to :admin
  has_many :borrow_item_admin_file
end
