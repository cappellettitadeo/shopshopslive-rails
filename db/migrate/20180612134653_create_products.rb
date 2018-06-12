class CreateProducts < ActiveRecord::Migration[5.1]
  def change
    create_table :products do |t|
      t.string :name
      t.integer :store_id
      t.integer :vendor_id
      t.string :ctr_product_id
      t.integer :source_id
      t.integer :scraper_id
      t.text :description
      t.text :keywords, array: true, default: []
      t.string :material
      t.boolean :available, default: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :products, :store_id
    add_index :products, :vendor_id
    add_index :products, :source_id
    add_index :products, :available
  end
end
