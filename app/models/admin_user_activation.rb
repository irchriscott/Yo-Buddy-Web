require 'securerandom'

class AdminUserActivation < ApplicationRecord

  	belongs_to :admin_user
  	before_save { self.key = SecureRandom.urlsafe_base64(25).upcase }

  	def get_key
  		
  		  self.key.insert(5, "-")
		    self.key.insert(11, "-")
		    self.key.insert(17, "-")
		    self.key.insert(23, "-")

		    return self.key
  	end

    def remaining
        return "#{(self.expary_date - Time.now).to_i / (24 * 60 * 60)} days"
    end
end
