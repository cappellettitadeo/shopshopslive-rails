class AddFullfillToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :tracking_url, :string
    add_column :orders, :shipping_status, :string
  end
end
