class AdminMailer < ApplicationMailer

  	def register_admin_user(email, password)
  		@email = email
  		@password = password
    	mail(to: email, subject: '[Yo Buddy] - Admin User Credintials')
  	end
end
