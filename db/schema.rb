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

ActiveRecord::Schema.define(version: 20170107184854) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string   "address"
    t.decimal  "lat"
    t.decimal  "lng"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_addresses_on_user_id", using: :btree
  end

  create_table "admins", force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,       null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "name"
    t.string   "username"
    t.string   "lastname"
    t.text     "avatar"
    t.string   "email"
    t.string   "mobile"
    t.json     "tokens"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.index ["email"], name: "index_admins_on_email", using: :btree
    t.index ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true, using: :btree
    t.index ["uid", "provider"], name: "index_admins_on_uid_and_provider", unique: true, using: :btree
  end

  create_table "alergies", force: :cascade do |t|
    t.string   "name",        null: false
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "alergy_by_dishes", force: :cascade do |t|
    t.integer  "alergy_id"
    t.integer  "dish_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alergy_id"], name: "index_alergy_by_dishes_on_alergy_id", using: :btree
    t.index ["dish_id"], name: "index_alergy_by_dishes_on_dish_id", using: :btree
  end

  create_table "alergy_by_users", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "alergy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["alergy_id"], name: "index_alergy_by_users_on_alergy_id", using: :btree
    t.index ["user_id"], name: "index_alergy_by_users_on_user_id", using: :btree
  end

  create_table "availabilities", force: :cascade do |t|
    t.date     "day",                        null: false
    t.integer  "count"
    t.boolean  "available",  default: true,  null: false
    t.time     "end_time"
    t.boolean  "repeat",     default: false, null: false
    t.integer  "dish_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["dish_id"], name: "index_availabilities_on_dish_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.string   "name",        null: false
    t.text     "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "category_by_dishes", force: :cascade do |t|
    t.integer  "category_id"
    t.integer  "dish_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["category_id"], name: "index_category_by_dishes_on_category_id", using: :btree
    t.index ["dish_id"], name: "index_category_by_dishes_on_dish_id", using: :btree
  end

  create_table "chefs", force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,       null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "name"
    t.string   "lastname"
    t.string   "username"
    t.text     "avatar"
    t.string   "email"
    t.string   "mobile"
    t.text     "description"
    t.text     "expertise",              default: "",      null: false
    t.text     "speciality",                               null: false
    t.integer  "type_chef"
    t.text     "food_types",             default: "",      null: false
    t.json     "tokens"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.date     "birthday"
    t.index ["email"], name: "index_chefs_on_email", using: :btree
    t.index ["reset_password_token"], name: "index_chefs_on_reset_password_token", unique: true, using: :btree
    t.index ["uid", "provider"], name: "index_chefs_on_uid_and_provider", unique: true, using: :btree
  end

  create_table "comment_votes", force: :cascade do |t|
    t.integer  "is_possitive", default: 1
    t.integer  "user_id"
    t.integer  "comment_id"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.index ["comment_id"], name: "index_comment_votes_on_comment_id", using: :btree
    t.index ["user_id", "comment_id"], name: "index_comment_votes_on_user_id_and_comment_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_comment_votes_on_user_id", using: :btree
  end

  create_table "comments", force: :cascade do |t|
    t.text     "description"
    t.integer  "user_id"
    t.integer  "dish_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["dish_id"], name: "index_comments_on_dish_id", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "dishes", force: :cascade do |t|
    t.string   "name",                         null: false
    t.text     "description"
    t.decimal  "price"
    t.decimal  "cooking_time"
    t.decimal  "calories"
    t.integer  "chef_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.decimal  "rating",       default: "0.0"
    t.index ["chef_id"], name: "index_dishes_on_chef_id", using: :btree
  end

  create_table "favorite_dishes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "dish_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dish_id"], name: "index_favorite_dishes_on_dish_id", using: :btree
    t.index ["user_id"], name: "index_favorite_dishes_on_user_id", using: :btree
  end

  create_table "followers", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "chef_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chef_id"], name: "index_followers_on_chef_id", using: :btree
    t.index ["user_id"], name: "index_followers_on_user_id", using: :btree
  end

  create_table "images", force: :cascade do |t|
    t.text     "description"
    t.integer  "order",       null: false
    t.string   "image"
    t.integer  "dish_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["dish_id", "order"], name: "index_images_on_dish_id_and_order", unique: true, using: :btree
    t.index ["dish_id"], name: "index_images_on_dish_id", using: :btree
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "count",          default: 1, null: false
    t.decimal  "price"
    t.text     "comment"
    t.date     "day"
    t.time     "estimated_time"
    t.integer  "address_id"
    t.integer  "user_id"
    t.integer  "dish_id"
    t.integer  "chef_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "payment_type"
    t.index ["address_id"], name: "index_orders_on_address_id", using: :btree
    t.index ["chef_id"], name: "index_orders_on_chef_id", using: :btree
    t.index ["dish_id"], name: "index_orders_on_dish_id", using: :btree
    t.index ["user_id"], name: "index_orders_on_user_id", using: :btree
  end

  create_table "rating_dishes", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "dish_id"
    t.decimal  "rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dish_id"], name: "index_rating_dishes_on_dish_id", using: :btree
    t.index ["user_id", "dish_id"], name: "index_rating_dishes_on_user_id_and_dish_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_rating_dishes_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        default: 0,       null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "name"
    t.string   "username"
    t.string   "lastname"
    t.string   "email"
    t.text     "avatar"
    t.string   "mobile"
    t.date     "birthday"
    t.json     "tokens"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.index ["email"], name: "index_users_on_email", using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true, using: :btree
  end

  add_foreign_key "addresses", "users"
  add_foreign_key "alergy_by_dishes", "alergies"
  add_foreign_key "alergy_by_dishes", "dishes"
  add_foreign_key "alergy_by_users", "alergies"
  add_foreign_key "alergy_by_users", "users"
  add_foreign_key "availabilities", "dishes"
  add_foreign_key "category_by_dishes", "categories"
  add_foreign_key "category_by_dishes", "dishes"
  add_foreign_key "comment_votes", "comments"
  add_foreign_key "comment_votes", "users"
  add_foreign_key "comments", "dishes"
  add_foreign_key "comments", "users"
  add_foreign_key "dishes", "chefs"
  add_foreign_key "favorite_dishes", "dishes"
  add_foreign_key "favorite_dishes", "users"
  add_foreign_key "followers", "chefs"
  add_foreign_key "followers", "users"
  add_foreign_key "images", "dishes"
  add_foreign_key "orders", "addresses"
  add_foreign_key "orders", "chefs"
  add_foreign_key "orders", "dishes"
  add_foreign_key "orders", "users"
  add_foreign_key "rating_dishes", "dishes"
  add_foreign_key "rating_dishes", "users"
end
