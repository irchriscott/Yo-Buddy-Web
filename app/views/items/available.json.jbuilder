json.array! (@dates) do |date|
	json.from date["from"].strftime("%b %d, %Y at %H:%M")
	json.to (date["to"] == "-") ? "-" : date["to"].strftime("%b %d, %Y at %H:%M")
	json.count date["count"]
end