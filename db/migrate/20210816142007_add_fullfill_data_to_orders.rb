class AddFullfillDataToOrders < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :fulfill_obj, :jsonb
  end
end
