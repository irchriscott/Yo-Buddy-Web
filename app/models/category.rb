class Category < ApplicationRecord
	
	has_many :subcategory 
	has_many :item
	has_many :usercategory

	def followers
		followers = Array.new
		self.usercategory.each do |user|
			followers.append(user.user.id)
		end
		return followers
	end
end
