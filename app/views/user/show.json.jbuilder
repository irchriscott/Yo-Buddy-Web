json.id @user.id
json.name @user.name
json.username @user.username
json.email @user.email
json.country @user.country_name
json.town @user.town
if @user.image? then
	json.image @user.image.url
else
	json.image "/assets/default.jpg"
end
json.gender @user.gender
json.followers @user.followers_count
json.following @user.following_count
json.url user_path(@user, format: :json)
json.items @user.item.count
json.requests @user.item_request.count
json.borrow @user.borrow_item_user.count