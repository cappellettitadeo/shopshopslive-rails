class CreateOrders < ActiveRecord::Migration[5.1]
  def change
    create_table :orders do |t|
      t.integer :user_id
      t.string :status
      t.datetime :completed_at
      t.datetime :refunded_at
      t.string :currency
      t.string :shipping_method
      t.string :full_address
      t.string :refund_id
      t.float :shipping_fee
      t.float :subtotal_price
      t.float :total_price
      t.float :tax
      t.string :invoice_url
      t.integer :shipping_address_id

      t.timestamps
    end
    add_index :orders, :user_id
    add_index :orders, :status
  end
end
