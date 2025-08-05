# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_08_05_014019) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "account_number", null: false
    t.decimal "balance", precision: 10, scale: 2, default: "0.0", null: false
    t.string "account_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_number"], name: "index_accounts_on_account_number", unique: true
    t.index ["customer_id", "account_type"], name: "index_accounts_on_customer_id_and_account_type"
    t.index ["customer_id"], name: "index_accounts_on_customer_id"
  end

  create_table "cards", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "card_token", null: false
    t.string "card_number", null: false
    t.string "last_four_digits", null: false
    t.string "pin_digest", null: false
    t.string "cvc_digest", null: false
    t.date "expiration_date", null: false
    t.string "card_type", null: false
    t.string "status", default: "active", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "status"], name: "index_cards_on_account_id_and_status"
    t.index ["account_id"], name: "index_cards_on_account_id"
    t.index ["card_number"], name: "index_cards_on_card_number", unique: true
    t.index ["card_token"], name: "index_cards_on_card_token", unique: true
    t.index ["expiration_date"], name: "index_cards_on_expiration_date"
    t.index ["last_four_digits"], name: "index_cards_on_last_four_digits"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "address", limit: 250, null: false
    t.string "city", null: false
    t.string "state", limit: 2, null: false
    t.string "zipcode", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["state"], name: "index_customers_on_state"
    t.index ["zipcode"], name: "index_customers_on_zipcode"
  end

  add_foreign_key "accounts", "customers"
  add_foreign_key "cards", "accounts"
end
