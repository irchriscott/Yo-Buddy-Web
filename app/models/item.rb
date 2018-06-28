class Item < ApplicationRecord
  	belongs_to :category
  	belongs_to :subcategory 
  	belongs_to :user
  	has_many :item_image
  	has_many :item_like
    has_many :comment
    has_many :borrow_item_user
    has_many :item_favourite

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
end
