class BorrowMessageImage < ApplicationRecord
  	belongs_to :borrow_message
  	mount_uploader :image, ImageUploader
	serialize :image, JSON
end
