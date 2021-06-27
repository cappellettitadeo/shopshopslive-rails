class AddTrackingToOrder < ActiveRecord::Migration[5.1]
  def change
    add_column :orders, :tracking_no, :string
    add_column :orders, :tracking_company, :string
  end
end
