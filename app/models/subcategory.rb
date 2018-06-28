class Subcategory < ApplicationRecord
  	belongs_to :category
  	has_many :item

  	validates :uuid, uniqueness: true
end
