class ItemRequest < ApplicationRecord
    belongs_to :user
    belongs_to :category
    belongs_to :subcategory
    has_many :item_request_suggestion
    has_many :item_request_image
    has_many :item_request_like

    validates :uuid, uniqueness: true

    def likes
        @likes = Array.new
        self.item_request_like.all do |user|
  		      @likes.append(user.user.id)
        end
        return @likes
    end

    def check_expiration
        from = self.from_date.localtime
        to = self.to_date.localtime
        now = Time.now
        if self.status == "pending" then
            if now > from and now < to then
                return "orange"
            elsif now > to then
                self.status = "failed"
                self.save
                return "red"
            else
                return "lightgreen"
            end 
        elsif self.status == "failed" then
            return "red"
        else
            return "green"
        end
    end
end
