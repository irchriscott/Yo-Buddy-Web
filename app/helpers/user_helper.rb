module UserHelper

	def login(user)
		session[:user_id] = user.id
	end

	def session_user
		@session_user ||= User.find_by(id: session[:user_id])
	end

	def is_logged_in?
		!session_user.nil?
	end

	def logout_user
		session.delete(:user_id)
		@session_user = nil
	end

	def user_id
		session[:user_id]
	end
end
