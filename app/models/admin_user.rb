class AdminUser < ApplicationRecord

  	belongs_to :user
  	has_one :admin_user_activation
    has_many :admin_user_keypay
    has_many :yb_key_usage
    
  	mount_uploader :image, ImageUploader

  	validates :email, uniqueness: true
  	
  	has_secure_password

  	def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
  	end
end
