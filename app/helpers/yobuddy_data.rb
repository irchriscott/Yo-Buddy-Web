module YobuddyData

	TRIAL_NUM_DAYS = 30

	PACKAGE_SILVER = "silver"
	PACKAGE_GOLD = "gold"
	PACKAGE_DIAMOND = "diamond"
	PACKAGE_PLATINUM = "platinum"
	PACKAGE_ULTIMATE = "ultimate"

	MAX_USERS_SILVER = 1
	MAX_USERS_GOLD = 3
	MAX_USERS_DIAMOND = 5
	MAX_USERS_PLATINUM = 10

	MAX_ITEMS_SILVER = 15
	MAX_ITEMS_GOLD = 50
	MAX_ITEMS_DIAMOND = 120
	MAX_ITEMS_PLATINUM = 250

	PRICE_SILVER = 9.99
	PRICE_GOLD = 14.99
	PRICE_DIAMOND = 24.99
	PRICE_PLATINUM = 34.55
	PRICE_ULTIMATE = 74.55

	ULTIMATE = nil
	
	def YobuddyData.get_yb_packages
		packages = Array.new

		packages.append({"package" => PACKAGE_SILVER, "items" => MAX_ITEMS_SILVER, "users" => MAX_USERS_SILVER, "price" => PRICE_SILVER})
		packages.append({"package" => PACKAGE_GOLD, "items" => MAX_ITEMS_GOLD, "users" => MAX_USERS_GOLD, "price" => PRICE_GOLD})
		packages.append({"package" => PACKAGE_DIAMOND, "items" => MAX_ITEMS_DIAMOND, "users" => MAX_USERS_DIAMOND, "price" => PRICE_DIAMOND})
		packages.append({"package" => PACKAGE_PLATINUM, "items" => MAX_ITEMS_PLATINUM, "users" => MAX_USERS_PLATINUM, "price" => PRICE_PLATINUM})
		packages.append({"package" => PACKAGE_ULTIMATE, "items" => ULTIMATE, "users" => ULTIMATE, "price" => PRICE_ULTIMATE})
		
		return packages
	end

end