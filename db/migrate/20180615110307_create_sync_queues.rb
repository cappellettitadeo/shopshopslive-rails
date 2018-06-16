class CreateSyncQueues < ActiveRecord::Migration[5.1]
  def change
    create_table :sync_queues do |t|
      t.string :target_type
      t.integer :target_id

      t.timestamps
    end
  end
end
