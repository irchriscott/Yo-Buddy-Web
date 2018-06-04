json.array! (@items) do |item|
	json.extract! item, :id, :name, :price, :currency, :per, :description, :status, :is_available, :created_at
	json.user item.user.json
	json.category item.category, :id, :name
	json.subcategory item.subcategory, :id, :name
	json.url item_path(item, format: :json)
	json.likes do 
		json.count item.item_like.all.count
		json.likers item.likes
	end
	json.favourites item.favourites
	json.comments item.comment.count
	json.borrow item.borrow_item_user.all.count
	json.images item.item_image, :id, :image
end