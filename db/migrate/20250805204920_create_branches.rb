class CreateBranches < ActiveRecord::Migration[8.0]
  def change
    create_table :branches do |t|
      t.string :name, null: false, limit: 250
      t.string :address, null: false, limit: 250
      t.string :city, null: false, limit: 100
      t.string :state, null: false, limit: 2
      t.string :zipcode, null: false, limit: 10
      t.string :country, null: false, limit: 50, default: 'USA'
      t.string :phone, null: false, limit: 10
      t.string :manager_name, limit: 250
      t.string :operating_hours, null: false
      t.string :branch_code, null: false, limit: 4

      t.timestamps
    end

    add_index :branches, :branch_code, unique: true
    add_index :branches, [:state, :city]
    add_index :branches, :zipcode
  end
end
