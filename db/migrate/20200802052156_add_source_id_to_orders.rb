class AddSourceIdToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :source_id, :string
    add_column :orders, :ctr_source_id, :string
    add_column :users, :source_id, :string
    add_column :users, :ctr_source_id, :string
  end
end
