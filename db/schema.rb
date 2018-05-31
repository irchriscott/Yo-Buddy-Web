# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180517043853) do

  create_table "active_admin_comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "addresses", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.float "longitude", limit: 24
    t.float "latitude", limit: 24
    t.string "address"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id"
  end

  create_table "admin_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "item_id"
    t.integer "borrow_id"
    t.string "status"
    t.boolean "is_available"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_admin_items_on_item_id"
  end

  create_table "admins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name"
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.string "image"
    t.string "privileges"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "borrow_item_admins", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "borrow_item_user_id"
    t.bigint "admin_id"
    t.string "status"
    t.string "state"
    t.string "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_borrow_item_admins_on_admin_id"
    t.index ["borrow_item_user_id"], name: "index_borrow_item_admins_on_borrow_item_user_id"
  end

  create_table "borrow_item_follow_ups", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "borrow_item_user_id"
    t.bigint "admin_id"
    t.string "about"
    t.string "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_borrow_item_follow_ups_on_admin_id"
    t.index ["borrow_item_user_id"], name: "index_borrow_item_follow_ups_on_borrow_item_user_id"
  end

  create_table "borrow_item_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "item_id"
    t.bigint "user_id"
    t.float "price", limit: 24
    t.string "currency"
    t.string "per"
    t.string "conditions"
    t.string "status"
    t.integer "numbers"
    t.datetime "from_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "to_date"
    t.integer "last_update_user_id"
    t.boolean "is_deleted"
    t.integer "count"
    t.index ["item_id"], name: "index_borrow_item_users_on_item_id"
    t.index ["user_id"], name: "index_borrow_item_users_on_user_id"
  end

  create_table "borrow_message_images", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "borrow_message_id"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["borrow_message_id"], name: "index_borrow_message_images_on_borrow_message_id"
  end

  create_table "borrow_messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "borrow_item_user_id"
    t.integer "sender_id"
    t.integer "receiver_id"
    t.string "message"
    t.string "status"
    t.boolean "is_deleted"
    t.integer "deleted_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_images"
    t.index ["borrow_item_user_id"], name: "index_borrow_messages_on_borrow_item_user_id"
  end

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.text "comment"
    t.boolean "is_deleted"
    t.bigint "user_id"
    t.bigint "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_comments_on_item_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "item_favourites", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "item_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_favourites_on_item_id"
    t.index ["user_id"], name: "index_item_favourites_on_user_id"
  end

  create_table "item_images", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "item_id"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_images_on_item_id"
  end

  create_table "item_likes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "user_id"
    t.bigint "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_likes_on_item_id"
    t.index ["user_id"], name: "index_item_likes_on_user_id"
  end

  create_table "item_request_images", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "item_request_id"
    t.string "image"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_request_id"], name: "index_item_request_images_on_item_request_id"
  end

  create_table "item_request_likes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "item_request_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_request_id"], name: "index_item_request_likes_on_item_request_id"
    t.index ["user_id"], name: "index_item_request_likes_on_user_id"
  end

  create_table "item_request_suggestions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "item_request_id"
    t.bigint "item_id"
    t.float "price", limit: 24
    t.string "currency"
    t.string "per"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_item_request_suggestions_on_item_id"
    t.index ["item_request_id"], name: "index_item_request_suggestions_on_item_request_id"
  end

  create_table "item_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "user_id"
    t.bigint "category_id"
    t.bigint "subcategory_id"
    t.string "title"
    t.string "description"
    t.datetime "from_date"
    t.datetime "to_date"
    t.string "per"
    t.string "status"
    t.boolean "is_deleted"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "min_price", limit: 24
    t.float "max_price", limit: 24
    t.string "currency"
    t.integer "numbers"
    t.integer "count"
    t.index ["category_id"], name: "index_item_requests_on_category_id"
    t.index ["subcategory_id"], name: "index_item_requests_on_subcategory_id"
    t.index ["user_id"], name: "index_item_requests_on_user_id"
  end

  create_table "items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name"
    t.float "price", limit: 24
    t.string "per"
    t.string "currency"
    t.string "description"
    t.string "status"
    t.boolean "is_available"
    t.boolean "is_deleted"
    t.bigint "category_id"
    t.bigint "subcategory_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_temp"
    t.integer "count"
    t.index ["category_id"], name: "index_items_on_category_id"
    t.index ["subcategory_id"], name: "index_items_on_subcategory_id"
    t.index ["user_id"], name: "index_items_on_user_id"
  end

  create_table "list_borrow_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "borrow_item_user_id"
    t.string "name"
    t.string "description"
    t.string "state"
    t.boolean "is_returned"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["borrow_item_user_id"], name: "index_list_borrow_items_on_borrow_item_user_id"
  end

  create_table "reports", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "user_id"
    t.string "ressource"
    t.integer "ressource_id"
    t.string "about"
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "subcategories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_subcategories_on_category_id"
  end

  create_table "user_follows", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "user_id"
    t.integer "following_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_follows_on_user_id"
  end

  create_table "usercategories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.bigint "user_id"
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_usercategories_on_category_id"
    t.index ["user_id"], name: "index_usercategories_on_user_id"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string "name"
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.string "country"
    t.string "town"
    t.string "number"
    t.string "image"
    t.string "gender"
    t.boolean "is_authenticated"
    t.boolean "is_private"
    t.boolean "is_blocked"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "addresses", "users"
  add_foreign_key "admin_items", "items"
  add_foreign_key "borrow_item_admins", "admins"
  add_foreign_key "borrow_item_admins", "borrow_item_users"
  add_foreign_key "borrow_item_follow_ups", "admins"
  add_foreign_key "borrow_item_follow_ups", "borrow_item_users"
  add_foreign_key "borrow_item_users", "items"
  add_foreign_key "borrow_item_users", "users"
  add_foreign_key "borrow_message_images", "borrow_messages"
  add_foreign_key "borrow_messages", "borrow_item_users"
  add_foreign_key "comments", "items"
  add_foreign_key "comments", "users"
  add_foreign_key "item_favourites", "items"
  add_foreign_key "item_favourites", "users"
  add_foreign_key "item_images", "items"
  add_foreign_key "item_likes", "items"
  add_foreign_key "item_likes", "users"
  add_foreign_key "item_request_images", "item_requests"
  add_foreign_key "item_request_likes", "item_requests"
  add_foreign_key "item_request_likes", "users"
  add_foreign_key "item_request_suggestions", "item_requests"
  add_foreign_key "item_request_suggestions", "items"
  add_foreign_key "item_requests", "categories"
  add_foreign_key "item_requests", "subcategories"
  add_foreign_key "item_requests", "users"
  add_foreign_key "items", "categories"
  add_foreign_key "items", "subcategories"
  add_foreign_key "items", "users"
  add_foreign_key "list_borrow_items", "borrow_item_users"
  add_foreign_key "reports", "users"
  add_foreign_key "subcategories", "categories"
  add_foreign_key "user_follows", "users"
  add_foreign_key "usercategories", "categories"
  add_foreign_key "usercategories", "users"
end