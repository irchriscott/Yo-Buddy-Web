class AdminMailer < ApplicationMailer

  	def register_admin_user(email, password, key)
  		@email = email
  		@password = password
  		@key = key
    	mail(to: email, subject: '[Yo Buddy] - Admin User Credintials')
  	end
end
