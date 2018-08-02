class ApplicationController < ActionController::Base

    protect_from_forgery with: :exception

  	include UserHelper

  	def check_active_user
    		if is_logged_in? then
      			user_id = (is_logged_in?) ? session[:user_id] : params[:follow][:session]
      			user = User.find(user_id)
      			if user.is_private == true then
        				if user.admin_user != nil then
        		        return user.admin_user.admin_user_activation.is_active && user.admin_user.admin_user_activation.yb_key.is_active
        				else
        				    return user.is_authenticated
        				end
      			else
                return true
      			end
    		else
            return false
    		end
  	end

    def run_sideqik
        BorrowUserMailerWorker.perform_async(1)
        ResetPasswordWorker.perform_async(true)
        BorrowUpdateWorker.perform_async(true)
    end
end
