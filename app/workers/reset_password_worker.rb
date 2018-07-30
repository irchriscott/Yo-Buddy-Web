class ResetPasswordWorker

	include Sidekiq::Worker

	def perform(*args)
		now = Time.now
		ResetPassword.all.each do |token|
			if args[0] and now > token.expiry_date then
				token.is_active = false
				token.save
			end
		end
	end

end
