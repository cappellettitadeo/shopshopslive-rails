class AddConfirmationIdToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :confirmation_id, :string
    add_index :orders, :confirmation_id
  end
end
