class CreateAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :accounts do |t|
      t.references :customer, null: false, foreign_key: true
      t.string :account_number, null: false
      t.decimal :balance, precision: 10, scale: 2, default: 0.00, null: false
      t.string :account_type, null: false

      t.timestamps
    end

    add_index :accounts, :account_number, unique: true
    add_index :accounts, [:customer_id, :account_type]
  end
end
