json.array! (@comments) do |comment|
	json.extract! comment, :id, :comment, :created_at
	json.user comment.user.json
end