class Admin < ApplicationRecord
    
    has_many :borrow_item_user

    mount_uploader :image, ImageUploader
    
    validates :name,  presence: true, length: { maximum: 50 }
    validates :username, uniqueness: true, length: {minimum: 5}
    validates :email, uniqueness: true
  	
  	has_secure_password

  	def Admin.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
  	end
end
