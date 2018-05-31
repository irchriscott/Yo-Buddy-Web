json.extract! @item, :id, :name, :price, :currency, :per, :description, :status, :is_available, :created_at

json.user do
	json.id @item.user.id
	json.name @item.user.name
	json.username @item.user.username
	json.email @item.user.email
	json.country @item.user.country_name
	json.town @item.user.town
	if @item.user.image? then
		json.image @item.user.image.url
	else
		json.image "/assets/default.jpg"
	end
	json.gender @item.user.gender
	json.followers @item.user.followers_count
	json.following @item.user.following_count
	json.url user_path(@item.user, format: :json)
end

json.category @item.category, :id, :name
json.subcategory @item.subcategory, :id, :name
json.url item_path(@item, format: :json)
json.likes do 
	json.count @item.item_like.all.count
	json.likers @item.likes
end
json.comments @item.comment.count
json.borrow @item.borrow_item_user.all.count

json.likers @item.item_like do |like|
	json.user do
		json.id like.user.id
		json.name like.user.name
		json.username like.user.username
		json.email like.user.email
		json.country like.user.country_name
		json.town like.user.town
		if like.user.image? then
			json.image like.user.image.url
		else
			json.image "/assets/default.jpg"
		end
		json.gender like.user.gender
		json.followers like.user.followers_count
		json.following like.user.following_count
		json.url user_path(like.user, format: :json)
	end
end

json.images @item.item_image, :id, :image

json.commenters @item.comment do |comment|
	json.id comment.id
	json.user do
		json.id comment.user.id
		json.name comment.user.name
		json.username comment.user.username
		json.email comment.user.email
		json.country comment.user.country_name
		json.town comment.user.town
		if comment.user.image? then
			json.image comment.user.image.url
		else
			json.image "/assets/default.jpg"
		end
		json.gender comment.user.gender
		json.followers comment.user.followers_count
		json.following comment.user.following_count
		json.url user_path(comment.user, format: :json)
	end
	json.comment comment.comment
	json.created_at comment.created_at
end