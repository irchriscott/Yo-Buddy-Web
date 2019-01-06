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

	def check_token
		token = params[:token]
		if !is_logged_in? then
			if token == nil or token == "" then
				respond_to do |format|
					format.json { render json:{"type" => "error", "text" => "Unauthorized"} }
					format.html{
						flash[:error] = "Login Required !!!"
						redirect_to new_user_path
					}
				end
			else
				user = User.find_by(token: token)
				if user == nil then
					respond_to do |format|
						format.json { render json:{"type" => "error", "text" => "Wrong token"} }
						format.html{
							flash[:error] = "Login Required !!!"
							redirect_to new_user_path
						}
						
					end
				else
					login user
				end
			end
		end
	end
end
