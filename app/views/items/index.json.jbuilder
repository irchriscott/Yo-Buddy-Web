json.array! (@items) do |item|
	json.extract! item, :id, :name, :price, :currency, :per, :description, :status, :is_available, :created_at
	json.user do
		json.id item.user.id
		json.name item.user.name
		json.username item.user.username
		json.email item.user.email
		json.country item.user.country_name
		json.town item.user.town
		if item.user.image? then
			json.image item.user.image.url
		else
			json.image "/assets/default.jpg"
		end
		json.gender item.user.gender
		json.followers item.user.followers_count
		json.following item.user.following_count
		json.url user_path(item.user, format: :json)
	end
	json.category item.category, :id, :name
	json.subcategory item.subcategory, :id, :name
	json.url item_path(item, format: :json)
	json.likes do 
		json.count item.item_like.all.count
		json.likers item.likes
	end
	json.comments item.comment.count
	json.borrow item.borrow_item_user.all.count
	json.images item.item_image, :id, :image
end