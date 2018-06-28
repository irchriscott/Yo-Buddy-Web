class Notification < ApplicationRecord
  
	def user_from
		return User.find(self.user_from_id).first
	end

	def user_to
		return User.find(self.user_to_id).first
	end
end
