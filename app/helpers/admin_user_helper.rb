module AdminUserHelper

	def login_admin_user(admin_user)
		session[:admin_user] = admin_user.id
	end

	def session_admin_user
		@admin_user ||= AdminUser.find_by(id: session[:admin_user])
	end

	def is_admin_user_logged_in?
		!session_admin_user.nil?
	end

	def logout_admin_user
		session.delete(:admin_user)
		@admin_user = nil
	end

	def admin_user_id
		session[:admin_user]
	end

	def check_admin_user_session
		if !is_admin_user_logged_in? then

			flash[:danger] = "Please, Log In !!!";
			redirect_to admin_u_index_path

		elsif !session_admin_user.admin_user_activation.is_active? and !session_admin_user.admin_user_activation.yb_key.is_active? then
			
			flash[:danger] = "Your Private Account Is Not Active !!!";
			redirect_to admin_u_activation_path
		end
	end
end
