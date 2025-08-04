class CreateCustomers < ActiveRecord::Migration[8.0]
  def change
    create_table :customers do |t|
      t.string :name, null: false, limit: 250
      t.string :address, null: false, limit: 250
      t.string :city, null: false
      t.string :state, null: false, limit: 2
      t.string :zipcode, null: false

      t.timestamps
    end

    add_index :customers, :zipcode
    add_index :customers, :state
  end
end
