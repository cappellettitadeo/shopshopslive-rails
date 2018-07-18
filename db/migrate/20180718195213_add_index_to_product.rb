class AddIndexToProduct < ActiveRecord::Migration[5.1]
  def change
    add_index :products, :name
    add_index :vendors, :name_en
  end
end
