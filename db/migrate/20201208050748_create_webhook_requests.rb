class CreateWebhookRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :webhook_requests do |t|
      t.jsonb :res
      t.string :source
      t.string :domain

      t.timestamps
    end
    add_index :webhook_requests, :domain
  end
end
