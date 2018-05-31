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

    mount_uploader :image, ImageUploader

    before_save { self.email = email.downcase, self.is_private = false if self.is_private == nil }

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

end
