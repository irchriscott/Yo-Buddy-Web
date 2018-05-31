class ItemRequestLike < ApplicationRecord
  belongs_to :item_request
  belongs_to :user
end
