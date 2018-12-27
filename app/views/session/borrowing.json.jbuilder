json.array! (@borrows) do |borrow|
	json.extract! borrow, :id, :price, :currency, :per, :conditions, :status, :is_deleted, :count, :numbers, :uuid
	json.from_date borrow.from_date.localtime
	json.to_date borrow.to_date.localtime
	json.created_at borrow.created_at.localtime
	json.updated_at borrow.updated_at.localtime
	json.item do
		json.extract! borrow.item, :id, :name, :price, :currency, :per, :description, :status, :is_available, :count
		json.created_at borrow.item.created_at.localtime
		json.user borrow.item.user.json
		json.category borrow.item.category, :id, :name, :icon
		json.subcategory borrow.item.subcategory, :id, :name
		json.uuid borrow.item.uuid
		json.url item_show_path(borrow.item.user.username, borrow.item.uuid, borrow.item, format: :json)
		json.likes do 
			json.count borrow.item.item_like.all.count
			json.likers borrow.item.likes
		end
		json.favourites borrow.item.favourites
		json.comments borrow.item.comment.count
		json.borrow borrow.item.borrow_item_user.all.count
		json.images borrow.item.item_image, :id, :image
	end
	json.expiration borrow.check_expiration
	json.borrow_total borrow.borrow_total
	json.code borrow.code
	json.penalties borrow.penalties
	json.deadline borrow.deadline
	json.user borrow.user.json
	json.last_updated_by User.find(borrow.last_update_user_id).json
	json.url item_borrow_path(borrow.uuid, borrow.item, borrow, format: :json)
	json.messages_url item_item_borrow_user_borrow_messages_path(borrow.item, borrow, format: :json)
end