# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

include YobuddyData

packages = YbPackage.create([
	{package: 'trial', items: 0, users: 0, price: 0},
	{package: YobuddyData::PACKAGE_SILVER, items: YobuddyData::MAX_ITEMS_SILVER, users: YobuddyData::MAX_USERS_SILVER, price: YobuddyData::PRICE_SILVER},
	{package: YobuddyData::PACKAGE_GOLD, items: YobuddyData::MAX_ITEMS_GOLD, users: YobuddyData::MAX_USERS_GOLD, price: YobuddyData::PRICE_GOLD},
	{package: YobuddyData::PACKAGE_DIAMOND, items: YobuddyData::MAX_ITEMS_DIAMOND, users: YobuddyData::MAX_USERS_DIAMOND, price: YobuddyData::PRICE_DIAMOND},
	{package: YobuddyData::PACKAGE_PLATINUM, items: YobuddyData::MAX_ITEMS_PLATINUM, users: YobuddyData::MAX_USERS_PLATINUM, price: YobuddyData::PRICE_PLATINUM},
	{package: YobuddyData::PACKAGE_ULTIMATE, items: YobuddyData::ULTIMATE, users: YobuddyData::ULTIMATE, price: YobuddyData::PRICE_ULTIMATE}
])