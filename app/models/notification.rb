class Notification < ApplicationRecord
  
	def user_from
		return User.find(self.user_from_id)
	end

	def user_to
		return User.find(self.user_to_id)
	end

	def notification
		if self.ressource.include?("update_item_request_suggest_status") then
			status = self.ressource.split(/_/).last
			item = ItemRequest.find(self.ressource_id)
			return {
				"from" => self.user_from.name,
				"image" => self.user_from.profile_image,
				"message" => "has updated your suggestion's status on his item request to #{status.capitalize!}",
				"icon" => "ion-ios-cart",
				"url" => "/items/request/#{item.user.username}/enc-dt-#{item.uuid}-#{item.id}",
				"category" => "item"
			}
		elsif self.ressource.include?("extend_borrow_request") then
			ext = self.ressource.split(/_/).last
			borrow = BorrowItemUser.find(self.ressource_id)
			if ["Integer", "Fixnum", "Float", "Bignum"].include?(ext.class.to_s) then
				return {
					"from" => self.user_from.name,
					"image" => self.user_from.profile_image,
					"message" => "want to extend the borrow period for #{ext} more #{borrow.per.downcase!}s",
					"icon" => "ion-arrow-expand",
					"url" => "/item/enc-dt-#{borrow.uuid}-#{borrow.item.id}-#{borrow.id}/borrow",
					"category" => "borrow"
				}
			else
				return {
					"from" => self.user_from.name,
					"image" => self.user_from.profile_image,
					"message" => "has updated your borrow extension request status to #{ext.capitalize!}",
					"icon" => "ion-arrow-expand",
					"url" => "/item/enc-dt-#{borrow.uuid}-#{borrow.item.id}-#{borrow.id}/borrow",
					"category" => "borrow"
				}
			end
			
		elsif self.ressource.include?("update_borrow") then
		 	status = self.ressource.split(/_/).last
			borrow = BorrowItemUser.find(self.ressource_id)
			if status == "content" then
				return {
					"from" => self.user_from.name,
					"image" => self.user_from.profile_image,
					"message" => "has updated your borrow aggreement content",
					"icon" => "ion-ios-cart",
					"url" => "/item/enc-dt-#{borrow.uuid}-#{borrow.item.id}-#{borrow.id}/borrow",
					"category" => "borrow"
				}
			elsif status == "report" then
				return {
					"from" => self.user_from.name,
					"image" => self.user_from.profile_image,
					"message" => "has sent a follow up report to your borrow",
					"icon" => "ion-ios-cart",
					"url" => "/item/enc-dt-#{borrow.uuid}-#{borrow.item.id}-#{borrow.id}/borrow",
					"category" => "borrow"
				}
			else
				return {
					"from" => self.user_from.name,
					"image" => self.user_from.profile_image,
					"message" => "has updated your borrow's status to #{status.capitalize!}",
					"icon" => "ion-ios-cart",
					"url" => "/item/enc-dt-#{borrow.uuid}-#{borrow.item.id}-#{borrow.id}/borrow",
					"category" => "borrow"
				}
			end
		else
			case self.ressource
				when "user_follow" then
					return {
						"from" => self.user_from.name,
						"image" => self.user_from.profile_image,
						"message" => "has started following you",
						"icon" => "ion-person",
						"url" => "/user/#{self.user_from.username}-#{self.user_from.id}/items",
						"category" => "user"
					}
				when "item_like" then
					item = Item.find(self.ressource_id)
					return {
						"from" => self.user_from.name,
						"image" => self.user_from.profile_image,
						"message" => "has liked your item",
						"icon" => "ion-ios-heart",
						"url" => "/item/#{item.user.username}/enc-dt-#{item.uuid}-#{item.id}",
						"category" => "item"
					}
				when "item_comment" then
					item = Item.find(self.ressource_id)
					return {
						"from" => self.user_from.name,
						"image" => self.user_from.profile_image,
						"message" => "has commented on your item",
						"icon" => "ion-ios-chatbubble",
						"url" => "/item/#{item.user.username}/enc-dt-#{item.uuid}-#{item.id}",
						"category" => "item"
					}
				when "item_request_like" then
					item = ItemRequest.find(self.ressource_id)
					return {
						"from" => self.user_from.name,
						"image" => self.user_from.profile_image,
						"message" => "has liked your item request",
						"icon" => "ion-ios-heart",
						"url" => "/items/request/#{item.user.username}/enc-dt-#{item.uuid}-#{item.id}",
						"category" => "item"
					}
				when "update_item_request_content" then
					item = ItemRequest.find(self.ressource_id)
					return {
						"from" => self.user_from.name,
						"image" => self.user_from.profile_image,
						"message" => "has updated the content of the item request on which you posted a suggestion",
						"icon" => "ion-forward",
						"url" => "/items/request/#{item.user.username}/enc-dt-#{item.uuid}-#{item.id}",
						"category" => "item"
					}
				when "item_request_suggest" then
					item = ItemRequest.find(self.ressource_id)
					return {
						"from" => self.user_from.name,
						"image" => self.user_from.profile_image,
						"message" => "has posted a suggestion to your item request",
						"icon" => "ion-ios-cart",
						"url" => "/items/request/#{item.user.username}/enc-dt-#{item.uuid}-#{item.id}",
						"category" => "item"
					}
				when "update_item_request_suggest_content" then
					item = ItemRequest.find(self.ressource_id)
					return {
						"from" => self.user_from.name,
						"image" => self.user_from.profile_image,
						"message" => "has updated his suggestion posted on your item request",
						"icon" => "ion-ios-cart",
						"url" => "/items/request/#{item.user.username}/enc-dt-#{item.uuid}-#{item.id}",
						"category" => "item"
					}
				when "item_borrow" then
					borrow = BorrowItemUser.find(self.ressource_id)
					return {
						"from" => self.user_from.name,
						"image" => self.user_from.profile_image,
						"message" => "has sent a borrow request for your item",
						"icon" => "ion-ios-cart",
						"url" => "/item/enc-dt-#{borrow.uuid}-#{borrow.item.id}-#{borrow.id}/borrow",
						"category" => "borrow"
					}
				when "item_borrow_else" then
					borrow = BorrowItemUser.find(self.ressource_id)
					return {
						"from" => self.user_from.name,
						"image" => self.user_from.profile_image,
						"message" => "has sent a borrow request that you requested on his item",
						"icon" => "ion-ios-cart",
						"url" => "/item/enc-dt-#{borrow.uuid}-#{borrow.item.id}-#{borrow.id}/borrow",
						"category" => "borrow"
					}
				when "update_borrow_required" then
					borrow = BorrowItemUser.find(self.ressource_id)
					return {
						"from" => "Yo Buddy Info",
						"image" => self.user_from.profile_image,
						"message" => "You are requested to update borrow item content #{borrow.code} especialy the From Date and the Status fields as the borrow deadline is getting closer without any common agreement taken.",
						"icon" => "ion-ios-cart",
						"url" => "/item/enc-dt-#{borrow.uuid}-#{borrow.item.id}-#{borrow.id}/borrow",
						"category" => "borrow"
					}
				when "self_update_item_borrow_failed" then
					borrow = BorrowItemUser.find(self.ressource_id)
					return {
						"from" => "Yo Buddy Info",
						"image" => self.user_from.profile_image,
						"message" => "The status of your item borrow #{borrow.code} has been updated to Failed",
						"icon" => "ion-ios-cart",
						"url" => "/item/enc-dt-#{borrow.uuid}-#{borrow.item.id}-#{borrow.id}/borrow",
						"category" => "borrow"
					}
				when "reminder_bring_item" then
					borrow = BorrowItemUser.find(self.ressource_id)
					return {
						"from" => "Yo Buddy Reminder",
						"image" => self.user_from.profile_image,
						"message" => "We wanted to remind you to bring the item of the borrow #{borrow.code} to Yo Buddy offices or proper location",
						"icon" => "ion-ios-alarm",
						"url" => "/item/enc-dt-#{borrow.uuid}-#{borrow.item.id}-#{borrow.id}/borrow",
						"category" => "reminder"
					}
				when "reminder_pick_item" then
					borrow = BorrowItemUser.find(self.ressource_id)
					return {
						"from" => "Yo Buddy Reminder",
						"image" => self.user_from.profile_image,
						"message" => "We wanted to remind you to come to pick the item of the borrow #{borrow.code} to Yo Buddy offices or proper location",
						"icon" => "ion-ios-alarm",
						"url" => "/item/enc-dt-#{borrow.uuid}-#{borrow.item.id}-#{borrow.id}/borrow",
						"category" => "reminder"
					}
				when "reminder_return_item" then
					borrow = BorrowItemUser.find(self.ressource_id)
					return {
						"from" => "Yo Buddy Reminder",
						"image" => self.user_from.profile_image,
						"message" => "We wanted to remind you to return the item of the borrow #{borrow.code} to Yo Buddy offices or proper location",
						"icon" => "ion-ios-alarm",
						"url" => "/item/enc-dt-#{borrow.uuid}-#{borrow.item.id}-#{borrow.id}/borrow",
						"category" => "reminder"
					}
				when "admin_user_key_trial" then
					return {
						"from" => "Yo Buddy Info",
						"image" => self.user_from.profile_image,
						"message" => "Your Admin-User trial key is about to expire. You are requested to buy one of our packages",
						"icon" => "ion-key",
						"url" => "/admin/u",
						"category" => "key"
					}
				when "admin_user_key_self_subscription" then
					activation = AdminUserActivation.find(self.ressource_id)
					return {
						"from" => "Yo Buddy Info",
						"image" => self.user_from.profile_image,
						"message" => "Your Admin-User trial key has expired. We have subscribed you to our #{activation.yb_key.yb_package.package.capitalize!} Package",
						"icon" => "ion-key",
						"url" => "/admin/u",
						"category" => "key"
					}
				when "admin_user_key_expiry_close" then
					return {
						"from" => "Yo Buddy Info",
						"image" => self.user_from.profile_image,
						"message" => "Your Admin-User key is about to expire. You are requested to buy another key",
						"icon" => "ion-key",
						"url" => "/admin/u",
						"category" => "key"
					}
				when "admin_user_key_expired" then
					return {
						"from" => "Yo Buddy Info",
						"image" => self.user_from.profile_image,
						"message" => "Your Admin-User key has expired. You are requested to buy another key",
						"icon" => "ion-key",
						"url" => "/admin/u",
						"category" => "key"
					}
			end
		end
	end
end
