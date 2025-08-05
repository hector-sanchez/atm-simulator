class CreateAtmMachines < ActiveRecord::Migration[8.0]
  def change
    create_table :atm_machines do |t|
      t.string :machine_id, null: false, limit: 8
      t.string :address, null: false, limit: 250
      t.string :city, null: false, limit: 100
      t.string :state, null: false, limit: 2
      t.string :zipcode, null: false, limit: 10
      t.string :country, null: false, limit: 50, default: 'USA'
      t.string :status, null: false, default: 'active'
      t.string :location_type, null: false
      t.decimal :cash_available, precision: 10, scale: 2, null: false, default: 0
      t.references :branch, null: true, foreign_key: true  # Optional reference

      t.timestamps
    end

    add_index :atm_machines, :machine_id, unique: true
    add_index :atm_machines, :status
    add_index :atm_machines, :location_type
    add_index :atm_machines, [:state, :city]
  end
end
