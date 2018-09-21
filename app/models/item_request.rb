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

    def json
        return {
            "id" => self.id,
            "name" => self.title,
            "uuid" => self.uuid,
            "category" => self.category.name,
            "subcategory" => self.subcategory.name,
            "user" => self.user.name,
            "min_price" => self.min_price,
            "max_price" => self.max_price,
            "currency" => self.currency,
            "per" => self.per,
            "location" => "#{self.user.town}, #{self.user.country_name}",
            "url" => "/items/request/#{self.user.username}/enc-dt-#{self.uuid}-#{self.id.to_s}",
            "likes" => self.item_request_like.count,
            "image" => self.item_request_image[0].image.url,
            "created_at" => self.created_at,
        }
    end
end
