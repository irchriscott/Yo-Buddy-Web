class BorrowItemAdminFile < ApplicationRecord
  belongs_to :borrow_item_admin
  mount_uploader :file, FileUploader
end
