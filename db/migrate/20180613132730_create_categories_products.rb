class CreateCategoriesProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :categories_products do |t|
      t.integer :product_id
      t.integer :category_id
    end
    add_index :categories_products, :product_id
    add_index :categories_products, :category_id
  end
end
