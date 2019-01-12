json.extract! @item, :id, :name, :price, :currency, :per, :description, :status, :is_available, :count, :sale_value

json.created_at @item.created_at.localtime
json.uuid @item.uuid

json.user @item.user.json

json.category @item.category, :id, :name, :icon
json.subcategory @item.subcategory, :id, :name
json.url item_show_path(@item.user.username, @item.uuid, @item, format: :json)
json.likes do 
	json.count @item.item_like.all.count
	json.likers @item.likes
end
json.favourites @item.favourites
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