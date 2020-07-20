class CreateLineItems < ActiveRecord::Migration[5.1]
  def change
    create_table :line_items do |t|
      t.integer :product_id
      t.integer :product_variant_id
      t.integer :order_id
      t.integer :quantity
      

      t.timestamps
    end
  end
end
