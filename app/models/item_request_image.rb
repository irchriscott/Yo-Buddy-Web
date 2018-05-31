class ItemRequestImage < ApplicationRecord
  	belongs_to :item_request
  	mount_uploader :image, ImageUploader
  	serialize :image, JSON
end
