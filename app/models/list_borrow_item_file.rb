class ListBorrowItemFile < ApplicationRecord
  belongs_to :list_borrow_item
  mount_uploader :file, FileUploader
end
