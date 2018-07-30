class ResetPasswordMailer < ApplicationMailer

	def send_link(email, link)
		@link = link
		mail(to: email, subject: '[Yo Buddy] - Reset Password Link')
	end

end
