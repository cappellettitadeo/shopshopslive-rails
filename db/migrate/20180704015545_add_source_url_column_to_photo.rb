class AddSourceUrlColumnToPhoto < ActiveRecord::Migration[5.1]
  def change
    add_column :photos, :source_url, :string
    add_index :photos, :source_url
  end
end
