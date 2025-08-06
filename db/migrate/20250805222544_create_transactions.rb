class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :card, null: false, foreign_key: true
      t.references :atm_machine, null: true, foreign_key: true # Optional - null for teller transactions
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :transaction_type, null: false # credit, debit
      t.string :source, null: false # atm, teller
      t.string :status, null: false # approved, denied, pending, cancelled
      t.string :reference_number, limit: 20, null: false
      t.text :description
      t.datetime :processed_at

      t.timestamps
    end

    # Indexes for performance
    add_index :transactions, :reference_number, unique: true
    add_index :transactions, [:card_id, :created_at]
    add_index :transactions, [:atm_machine_id, :created_at]
    add_index :transactions, [:status, :created_at]
    add_index :transactions, :transaction_type
    add_index :transactions, :source
  end
end
