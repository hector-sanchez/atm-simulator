class CreateCards < ActiveRecord::Migration[8.0]
  def change
    create_table :cards do |t|
      t.references :account, null: false, foreign_key: true
      t.string :card_token, null: false
      t.string :card_number, null: false
      t.string :last_four_digits, null: false
      t.string :pin_digest, null: false
      t.string :cvc_digest, null: false
      t.date :expiration_date, null: false
      t.string :card_type, null: false
      t.string :status, null: false, default: 'active'

      t.timestamps
    end

    add_index :cards, :card_token, unique: true
    add_index :cards, :card_number, unique: true
    add_index :cards, :last_four_digits
    add_index :cards, [:account_id, :status]
    add_index :cards, :expiration_date
  end
end
