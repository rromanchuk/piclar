# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.


ActiveRecord::Schema.define(:version => 20130210105916) do

  create_table "comments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "feed_item_id"
    t.string   "comment"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "comments", ["feed_item_id"], :name => "index_comments_on_feed_item_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "feed_items", :force => true do |t|
    t.integer  "user_id"
    t.integer  "place_id"
    t.integer  "rating"
    t.boolean  "is_active",          :default => true
    t.string   "review"
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  add_index "feed_items", ["place_id"], :name => "index_feed_items_on_place_id"
  add_index "feed_items", ["user_id"], :name => "index_feed_items_on_user_id"

  create_table "foursquare_categories", :force => true do |t|
    t.string  "foursquare_id"
    t.integer "parent_id"
    t.string  "name"
    t.string  "plural_name"
    t.string  "short_name"
    t.string  "icon"
  end

  add_index "foursquare_categories", ["foursquare_id"], :name => "index_foursquare_categories_on_foursquare_id"
  add_index "foursquare_categories", ["parent_id"], :name => "index_foursquare_categories_on_parent_id"

  create_table "likes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "feed_item_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "likes", ["feed_item_id"], :name => "index_likes_on_feed_item_id"
  add_index "likes", ["user_id"], :name => "index_likes_on_user_id"

  create_table "notifications", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.boolean  "is_read",           :default => false
    t.string   "notification_type"
    t.boolean  "is_active",         :default => true
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "notifications", ["receiver_id"], :name => "index_notifications_on_receiver_id"
  add_index "notifications", ["sender_id"], :name => "index_notifications_on_sender_id"

  create_table "places", :force => true do |t|
    t.string   "title"
    t.string   "city_name"
    t.string   "address"
    t.string   "phone"
    t.integer  "type"
    t.string   "type_text"
    t.string   "foursquare_id"
    t.decimal  "latitude",      :precision => 15, :scale => 10
    t.decimal  "longitude",     :precision => 15, :scale => 10
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "places", ["foursquare_id"], :name => "index_places_on_foursquare_id"

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], :name => "index_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "",   :null => false
    t.string   "encrypted_password",                  :default => "",   :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.boolean  "is_active",                           :default => true
    t.string   "location"
    t.string   "city"
    t.string   "country"
    t.integer  "gender",                              :default => 0
    t.datetime "birthday"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "name"
    t.string   "provider"
    t.string   "vk_token"
    t.string   "fb_token"
    t.integer  "fbuid",                  :limit => 8
    t.integer  "vkuid",                  :limit => 8
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "push_comments",                       :default => true
    t.boolean  "push_posts",                          :default => true
    t.boolean  "push_likes",                          :default => true
    t.boolean  "push_friends",                        :default => true
    t.boolean  "save_filtered",                       :default => true
    t.boolean  "save_original",                       :default => true
    t.string   "fsq_token"
  end

  add_index "users", ["authentication_token"], :name => "index_users_on_authentication_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
