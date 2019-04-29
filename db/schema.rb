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

ActiveRecord::Schema.define(version: 2019_04_29_190852) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "charges", force: :cascade do |t|
    t.integer "amount", null: false
    t.json "stripe_response"
    t.string "comment", null: false
    t.string "state", null: false
    t.string "stripe_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.bigint "purchase_id", null: false
    t.string "transfer", null: false
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

  create_table "details", force: :cascade do |t|
    t.bigint "claim_id", null: false
    t.string "import_key"
    t.string "first_name"
    t.string "preferred_first_name"
    t.string "preferred_last_name"
    t.string "badge_title"
    t.string "badge_subtitle"
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "province"
    t.string "postal"
    t.string "country"
    t.string "publication_format"
    t.boolean "show_in_listings", default: true
    t.boolean "share_with_future_worldcons", default: true
    t.boolean "interest_volunteering"
    t.boolean "interest_accessibility_services"
    t.boolean "interest_being_on_program"
    t.boolean "interest_dealers"
    t.boolean "interest_selling_at_art_show"
    t.boolean "interest_exhibiting"
    t.boolean "interest_performing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.string "last_name"
    t.index ["claim_id"], name: "index_details_on_claim_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.string "name", null: false
    t.integer "price", null: false
    t.datetime "active_from", null: false
    t.datetime "active_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
  end

  create_table "notes", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "purchase_id", null: false
    t.bigint "membership_id", null: false
    t.datetime "active_from", null: false
    t.datetime "active_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["membership_id"], name: "index_orders_on_membership_id"
    t.index ["purchase_id"], name: "index_orders_on_purchase_id"
  end

  create_table "purchases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "state", null: false
    t.integer "membership_number", null: false
  end

  create_table "supports", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["confirmation_token"], name: "index_supports_on_confirmation_token", unique: true
    t.index ["email"], name: "index_supports_on_email", unique: true
    t.index ["reset_password_token"], name: "index_supports_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_supports_on_unlock_token", unique: true
  end

  create_table "transfers", force: :cascade do |t|
    t.bigint "purchase_id", null: false
    t.string "new_owner_email", null: false
    t.datetime "active_from", null: false
    t.datetime "active_to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["purchase_id"], name: "index_transfers_on_purchase_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.index ["email"], name: "index_users_on_email"
  end

  add_foreign_key "charges", "purchases"
  add_foreign_key "charges", "users"
  add_foreign_key "claims", "purchases"
  add_foreign_key "claims", "users"
  add_foreign_key "notes", "users"
  add_foreign_key "orders", "memberships"
  add_foreign_key "orders", "purchases"
  add_foreign_key "transfers", "purchases"
end
