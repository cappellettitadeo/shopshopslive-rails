class ChangeCtrSourceIdInUsers < ActiveRecord::Migration[5.1]
  def change
    rename_column :users, :ctr_source_id, :ctr_user_id
    rename_column :orders, :ctr_source_id, :ctr_order_id
  end
end
