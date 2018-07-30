class UserMailer < ApplicationMailer

  	def private_user
   		@user = params[:user]
        mail(to: @user.email, subject: '[Yo Buddy] - Create Admin-User Account')
  	end
end
