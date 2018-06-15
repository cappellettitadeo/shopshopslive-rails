class CreateSyncLogs < ActiveRecord::Migration[5.1]
  def change
    create_table :sync_logs do |t|
      t.string :method
      t.string :url
      t.integer :status_code
      t.string :target_type
      t.text :target_ids, array: true, default: []
      t.text :raw_request
      t.text :raw_response

      t.timestamps
    end
  end
end
