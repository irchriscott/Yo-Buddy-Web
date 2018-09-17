json.array! (@categories) do |category|
	json.extract! category, :id, :name, :uuid, :description, :icon
	json.subcategories category.subcategory do |subcategory|
		json.id subcategory.id
		json.name subcategory.name
	end
	json.items category.item.count
end