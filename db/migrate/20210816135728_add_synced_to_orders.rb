class AddSyncedToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :sync_at, :datetime
  end
end
