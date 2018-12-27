json.array! (@messages) do |message|
	json.extract! message, :id, :message, :status, :is_deleted
	json.created_at message.created_at.localtime
	json.type (message.sender_id != 0 && message.receiver_id != 0) ? "user" : "admin"
	json.sender (message.sender_id != 0) ? message.sender.json : message.borrow_item_user.user.json
	json.receiver (message.receiver_id != 0) ? message.receiver.json : message.borrow_item_user.item.user.json
	json.has_images (message.has_images == nil) ? false : message.has_images
	json.images message.borrow_message_image.all, :id, :image
end