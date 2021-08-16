class AddSourceOrderIdToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :source_order_id, :string
  end
end
