json.array! (@items) do |item|
	json.extract! item, :id, :name, :price, :currency, :per, :description, :status, :is_available, :count
	json.created_at item.created_at.localtime
	json.user item.user.json
	json.category item.category, :id, :name, :icon
	json.subcategory item.subcategory, :id, :name
	json.uuid item.uuid
	json.url item_show_path(item.user.username, item.uuid, item, format: :json)
	json.likes do 
		json.count item.item_like.all.count
		json.likers item.likes
	end
	json.favourites item.favourites
	json.comments item.comment.count
	json.borrow item.borrow_item_user.all.count
	json.images item.item_image, :id, :image
end