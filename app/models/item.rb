class Item < ApplicationRecord

    include ApplicationHelper

  	belongs_to :category
  	belongs_to :subcategory 
  	belongs_to :user
  	has_many :item_image
  	has_many :item_like
    has_many :comment
    has_many :borrow_item_user
    has_many :item_favourite
    has_one :admin_item

    before_save { self.is_temp = false if self.is_temp == nil }
    validates :count, length: {minimum: 1}
    validates :uuid, uniqueness: true

  	def likes
    		@likes = Array.new
    		for like in self.item_like
    			@likes.append(like.user.id)
    		end
        return @likes
  	end

    def favourites
        @favourites = Array.new
        for favourite in self.item_favourite
          @favourites.append(favourite.user.id)
        end
        return @favourites
    end

    def price_to_s
        return number_to_s(self.price)
    end

    def time_ago
        return time_ago_in_words(self.created_at)
    end

    def available
        counts = 0
        borrows = self.borrow_item_user.where("status = :status OR status = :status_else", {status: "accepted", status_else: "rendered"})
        if borrows != nil
            borrows.each{ |borrow|
                counts += borrow.count.to_i
            }
        end
        if self.count < counts
          return 0
        else
          return self.count - counts
        end
    end

    def json
        return {
            "id" => self.id,
            "name" => self.name,
            "uuid" => self.uuid,
            "category" => self.category.name,
            "subcategory" => self.subcategory.name,
            "user" => self.user.name,
            "price" => self.price,
            "currency" => self.currency,
            "per" => self.per,
            "location" => "#{self.user.town}, #{self.user.country_name}",
            "url" => "/item/#{self.user.username}/enc-dt-#{self.uuid}-#{self.id.to_s}",
            "likes" => self.item_like.count,
            "borrows" => self.borrow_item_user.count,
            "image" => self.item_image[0].image.url,
            "created_at" => self.created_at,
        }
    end

end
