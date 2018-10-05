require 'securerandom'

class User < ApplicationRecord
	
    has_many :item 
    has_many :usercategory
    has_one :address
    has_many :item_like
    has_many :borrow_item_user
    has_many :comment
    has_many :item_favourite
    has_many :item_request
    has_many :item_request_like
    has_one :admin_user

    mount_uploader :image, ImageUploader

    before_save { self.token = SecureRandom.urlsafe_base64(self.name.length + self.username.length + self.email.length), self.email = email.downcase, self.is_private = false if self.is_private == nil }

  	validates :name,  presence: true, length: { maximum: 50 }
    validates :username, uniqueness: true, length: {minimum: 5}
    validates :email, uniqueness: true
  	
  	has_secure_password

  	def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
  	end

    def country_name
        full_country = ISO3166::Country[country]
        full_country.translations[I18n.locale.to_s] || full_country.name
    end

    def save_profile_image
        filename = image.original_filename
        folder = "uploads/profile/#{username}"

        FileUtils::mkdir_p folder

        file = File.open File.join(folder, filename), "wb"
        file.write image.read()
        file.close

        self.image = nil
        update image_filename: filename
    end

    def following
        users = Array.new
        UserFollow.where(user_id: self.id).each do |user|
            users.append(user.following.id)
        end
        return users
    end

    def following_count
        return self.following.count
    end

    def followers
        users = Array.new
        UserFollow.where(following_id: self.id).each do |user|
            users.append(user.user.id)
        end
        return users
    end

    def followers_count
        return self.followers.count
    end

    def notifications
        return Notification.where(user_to_id: self.id).where(is_read: false).order(created_at: :desc)
    end

    def notification_count
        return self.notifications.count
    end

    def profile_image
        return (self.image?) ? "http://127.0.0.1:3000/#{self.image.url}" : "http://127.0.0.1:3000/assets/default.jpg"
    end

    def json
        return {
            "id" => self.id,
            "name" => self.name,
            "username" => self.username,
            "email" => self.email,
            "country" => self.country_name,
            "town" => self.town,
            "image" => (self.image?) ? self.image.url : "/assets/default.jpg",
            "gender" => self.gender,
            "followers" => self.followers_count,
            "following" => self.following_count,
            "url" => "/user/#{self.id}.json",
            "url_html" => "/user/#{self.username}-#{self.id}/items",
            "items" => self.item.count,
            "requests" => self.item_request.count,
            "borrow" => self.borrow_item_user.count,
            "followers_list" => self.followers,
            "following_list" => self.following,
            "favourites" => self.item_favourite.count,
            "created_at" => self.created_at
        }
    end

end
