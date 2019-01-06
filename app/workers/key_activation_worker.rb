class KeyActivationWorker

  	include Sidekiq::Worker

  	def perform(*args)

    	AdminUser.all.each do |admin|
    		
    		if admin.admin_user_activation.is_active? and admin.admin_user_activation.yb_key.is_active? then

    			items = get_user_items(admin.user.id)
	    		remaining_time =  (admin.admin_user_activation.yb_key.updated_at.localtime.to_i + (admin.admin_user_activation.yb_key.remaining.to_i * 24 * 60 * 60)) - Time.now.to_i
	    		remaining = remaining_time / (24 * 60 * 60)
    			
    			if admin.admin_user_activation.yb_key.yb_package.package == "trial" then

	    			if remaining.truncate == 5 || remaining.truncate == 1 then
	    			
	    				admin.admin_user_activation.yb_key.remaining = remaining
	    				admin.admin_user_activation.yb_key.save
	    			
	    				ReminderMailer.activate_key(admin).deliver_now
	    				Notification.create([{user_from_id: admin.user.id, user_to_id: admin.user.id , ressource: "admin_user_key_trial", ressource_id: admin.admin_user_activation.id, is_read: false}])
	    			
	    			elsif remaining <= 0 then
	    				
	    				package = get_preferable_package(items)
	    				
	    				admin.admin_user_activation.yb_key.remaining = 0
	    				admin.admin_user_activation.yb_key.is_active = false
	    				admin.admin_user_activation.yb_key.status = "desactivated"
	    				admin.admin_user_activation.yb_key.save

	    				admin.admin_user_activation.is_active = false
	    				admin.admin_user_activation.save

	    				ReminderMailer.self_subscription(admin, package).deliver_now
	    				Notification.create([{user_from_id: admin.user.id, user_to_id: admin.user.id , ressource: "admin_user_key_self_subscription", ressource_id: admin.admin_user_activation.id, is_read: false}])
	    			else
	    				admin.admin_user_activation.yb_key.remaining = remaining
	    				admin.admin_user_activation.yb_key.save
	    			end
	    		else
	    			if admin.admin_user_activation.yb_key.remaining == 5 || admin.admin_user_activation.yb_key.remaining == 1 then
	    				
	    				admin.admin_user_activation.yb_key.remaining = remaining
	    				admin.admin_user_activation.yb_key.save

	    				ReminderMailer.activate_key(admin).deliver_now
	    				Notification.create([{user_from_id: admin.user.id, user_to_id: admin.user.id , ressource: "admin_user_key_expiry_close", ressource_id: admin.admin_user_activation.id, is_read: false}])
	    			
	    			elsif admin.admin_user_activation.yb_key.remaining == 0 then

	    				admin.admin_user_activation.yb_key.remaining = 0
	    				admin.admin_user_activation.yb_key.is_active = false
	    				admin.admin_user_activation.yb_key.status = "desactivated"
	    				admin.admin_user_activation.yb_key.save

	    				admin.admin_user_activation.is_active = false
	    				admin.admin_user_activation.save

	    				ReminderMailer.key_expired(admin).deliver_now
	    				Notification.create([{user_from_id: admin.user.id, user_to_id: admin.user.id , ressource: "admin_user_key_expired", ressource_id: admin.admin_user_activation.id, is_read: false}])
	    			else
	    				admin.admin_user_activation.yb_key.remaining = remaining
	    				admin.admin_user_activation.yb_key.save
	    			end
	    		end
    		end
    	end
  	end

  	def get_user_items(user)
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
	    		return "ultimate"
	    end
  	end
end
