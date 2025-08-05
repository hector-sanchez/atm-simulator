class AddCardholderNameToCards < ActiveRecord::Migration[8.0]
  def change
    add_column :cards, :cardholder_name, :string
  end
end
