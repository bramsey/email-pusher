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

ActiveRecord::Schema.define(:version => 20110815174059) do

  create_table "accounts", :force => true do |t|
    t.string   "username"
    t.integer  "user_id"
    t.boolean  "active"
    t.string   "token"
    t.string   "secret"
    t.integer  "notification_service_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["user_id"], :name => "index_accounts_on_user_id"

  create_table "contacts", :force => true do |t|
    t.string   "email"
    t.integer  "user_id"
    t.boolean  "active",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["email"], :name => "index_contacts_on_email"

  create_table "invites", :force => true do |t|
    t.string   "email"
    t.boolean  "approved",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "invites", ["email"], :name => "index_invites_on_email", :unique => true

  create_table "notification_services", :force => true do |t|
    t.integer  "user_id"
    t.string   "type"
    t.string   "username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "notifo_services", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                          :default => "", :null => false
    t.string   "encrypted_password",              :limit => 128, :default => "", :null => false
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                  :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "listening"
    t.integer  "default_notification_service_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
