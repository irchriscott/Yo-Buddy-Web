json.array! (@users) do |user|
	json.extract! user, :id, :name, :username, :email, :town, :is_private, :created_at
	json.image (user.image?) ? user.image.url : "/assets/default.jpg"
	json.country user.country_name
end