class AddIndexToCtrIds < ActiveRecord::Migration[5.1]
  def change
    add_index :product_variants, :ctr_sku_id
    add_index :stores, :ctr_store_id
    add_index :vendors, :ctr_vendor_id
  end
end
