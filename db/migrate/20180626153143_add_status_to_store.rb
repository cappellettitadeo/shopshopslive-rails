class AddStatusToStore < ActiveRecord::Migration[5.1]
  def change
    rename_column :stores, :source, :source_type
    add_column :stores, :source_url, :string
    add_column :stores, :status, :string, default: 'active'
  end
end
