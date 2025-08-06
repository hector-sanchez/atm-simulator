class RenameSourceTypeToSource < ActiveRecord::Migration[8.0]
  def change
    rename_column :transactions, :source_type, :source
  end
end
