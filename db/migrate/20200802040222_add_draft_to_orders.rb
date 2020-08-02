class AddDraftToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :draft, :boolean, default: false
  end
end
