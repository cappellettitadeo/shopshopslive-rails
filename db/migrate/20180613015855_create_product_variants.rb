class CreateProductVariants < ActiveRecord::Migration[5.1]
  def change
    create_table :product_variants do |t|
      t.string :name
      t.integer :product_id
      t.string :ctr_sku_id
      t.string :image_id
      t.integer :source_id
      t.string :source_sku
      t.float :original_price
      t.float :price
      t.boolean :discounted
      t.string :color
      t.integer :size_id
      t.integer :inventory
      t.string :currency
      t.string :barcode
      t.float :weight
      t.string :weight_unit
      t.boolean :available
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :product_variants, :product_id
    add_index :product_variants, :source_id
    add_index :product_variants, :image_id
  end
end
