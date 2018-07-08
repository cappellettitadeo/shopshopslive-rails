class AddNameEnToCategory < ActiveRecord::Migration[5.1]
  def change
    add_column :categories, :name_en, :string
    add_index :categories, :name_en
  end
end
