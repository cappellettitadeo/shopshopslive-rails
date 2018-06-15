class CreateStoreHours < ActiveRecord::Migration[5.1]
  def change
    create_table :store_hours do |t|
      t.integer :store_id
      t.string :hour_type
      t.datetime :open_time
      t.datetime :close_time
      t.integer :weekday
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :store_hours, :store_id
  end
end
