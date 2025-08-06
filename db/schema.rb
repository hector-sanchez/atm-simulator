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

ActiveRecord::Schema[8.0].define(version: 2025_08_06_060726) do
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

  create_table "atm_machines", force: :cascade do |t|
    t.string "machine_id", limit: 8, null: false
    t.string "address", limit: 250, null: false
    t.string "city", limit: 100, null: false
    t.string "state", limit: 2, null: false
    t.string "zipcode", limit: 10, null: false
    t.string "country", limit: 50, default: "USA", null: false
    t.string "status", default: "active", null: false
    t.string "location_type", null: false
    t.decimal "cash_available", precision: 10, scale: 2, default: "0.0", null: false
    t.bigint "branch_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_atm_machines_on_branch_id"
    t.index ["location_type"], name: "index_atm_machines_on_location_type"
    t.index ["machine_id"], name: "index_atm_machines_on_machine_id", unique: true
    t.index ["state", "city"], name: "index_atm_machines_on_state_and_city"
    t.index ["status"], name: "index_atm_machines_on_status"
  end

  create_table "branches", force: :cascade do |t|
    t.string "name", limit: 250, null: false
    t.string "address", limit: 250, null: false
    t.string "city", limit: 100, null: false
    t.string "state", limit: 2, null: false
    t.string "zipcode", limit: 10, null: false
    t.string "country", limit: 50, default: "USA", null: false
    t.string "phone", limit: 10, null: false
    t.string "manager_name", limit: 250
    t.string "operating_hours", null: false
    t.string "branch_code", limit: 4, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_code"], name: "index_branches_on_branch_code", unique: true
    t.index ["state", "city"], name: "index_branches_on_state_and_city"
    t.index ["zipcode"], name: "index_branches_on_zipcode"
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
    t.string "cardholder_name"
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

  create_table "transactions", force: :cascade do |t|
    t.bigint "card_id", null: false
    t.bigint "atm_machine_id"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "transaction_type", null: false
    t.string "source", null: false
    t.string "status", null: false
    t.string "reference_number", limit: 20, null: false
    t.text "description"
    t.datetime "processed_at"
    t.decimal "account_balance_after", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["atm_machine_id", "created_at"], name: "index_transactions_on_atm_machine_id_and_created_at"
    t.index ["atm_machine_id"], name: "index_transactions_on_atm_machine_id"
    t.index ["card_id", "created_at"], name: "index_transactions_on_card_id_and_created_at"
    t.index ["card_id"], name: "index_transactions_on_card_id"
    t.index ["reference_number"], name: "index_transactions_on_reference_number", unique: true
    t.index ["source"], name: "index_transactions_on_source"
    t.index ["status", "created_at"], name: "index_transactions_on_status_and_created_at"
    t.index ["transaction_type"], name: "index_transactions_on_transaction_type"
  end

  add_foreign_key "accounts", "customers"
  add_foreign_key "atm_machines", "branches"
  add_foreign_key "cards", "accounts"
  add_foreign_key "transactions", "atm_machines"
  add_foreign_key "transactions", "cards"
end
