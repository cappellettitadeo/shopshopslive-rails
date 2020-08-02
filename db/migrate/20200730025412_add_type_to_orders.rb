class AddTypeToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :order_type, :integer, default: 0
    add_column :orders, :master_order_id, :integer
    add_column :orders, :store_id, :integer
    add_index :orders, :master_order_id
  end
end
