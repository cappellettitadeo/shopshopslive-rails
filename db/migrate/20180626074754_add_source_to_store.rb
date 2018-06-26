class AddSourceToStore < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :source, :string
    add_column :stores, :source_id, :string
    add_column :stores, :source_token, :string
  end
end
