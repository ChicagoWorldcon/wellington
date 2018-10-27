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

ActiveRecord::Schema.define(version: 20181027041136) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "charges", force: :cascade do |t|
    t.integer "cost", null: false
    t.json "stripe_response"
    t.string "comment", null: false
    t.string "state", null: false
    t.string "stripe_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "purchase_id", null: false
    t.index ["purchase_id"], name: "index_charges_on_purchase_id"
    t.index ["user_id"], name: "index_charges_on_user_id"
  end

  create_table "claims", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "purchase_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "active_from", null: false
    t.datetime "active_to"
    t.index ["purchase_id"], name: "index_claims_on_purchase_id"
    t.index ["user_id"], name: "index_claims_on_user_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.string "level", null: false
    t.integer "worth", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
  end

  add_foreign_key "charges", "purchases"
  add_foreign_key "charges", "users"
  add_foreign_key "claims", "purchases"
  add_foreign_key "claims", "users"
end
