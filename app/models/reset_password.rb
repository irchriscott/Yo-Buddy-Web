class ResetPassword < ApplicationRecord
	
	validates :token, uniqueness: true

	def user
		if self.resource == "user" then
			return User.find self.resource_id
		elsif self.resource == "admin_user" then
			return AdminUser.find self.resource_id
		elsif self.resource == "admin" then
			return Admin.find self.resource_id		
		end
	end

end
