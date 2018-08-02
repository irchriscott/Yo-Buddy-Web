require 'securerandom'

module ApplicationHelper

	include UserHelper

	def generate_uuid(text, length=16)
		return (text.gsub(' ', '-') + '-' + SecureRandom.urlsafe_base64(length)).downcase
	end

	def check_active
		@active = check_active_user
	end

	def get_expiry_date(days)
		return Time.now + (days.to_i * 24 * 60 * 60)
	end

	def get_sum_items(user)
		items = 0
	  	Item.where(user_id: user).each do |item|
	  		items += item.count.to_i
	  	end
	  	return items
	end

	def get_preferable_package(items)
  		
  		case items
	    	when 0..15 then
	  			return "silver"
	   		when 16..50 then
	  			return "gold"
	    	when 51..120 then
	    		return "diamond"
	    	when 121..250 then
	    		return "platinum"
	    	else
	    		return "altimate"
	    end
  	end

	def can_add_item(user, count)
		@user = User.find(user)
  		if @user.is_private? then
  			items = get_sum_items(@user.id)
  			max_items = @user.admin_user.admin_user_activation.yb_key.yb_package.items
  			if @user.admin_user.admin_user_activation.is_active? and @user.admin_user.admin_user_activation.yb_key.is_active? then
  				if @user.admin_user.admin_user_activation.yb_key.yb_package.package == "trial" or @user.admin_user.admin_user_activation.yb_key.yb_package.package == "altimate" then
  					return true
  				else
  					return (items + count) <= max_items
  				end
  			else
  				return false
  			end
  		else
  			return true
  		end
  	end
end
