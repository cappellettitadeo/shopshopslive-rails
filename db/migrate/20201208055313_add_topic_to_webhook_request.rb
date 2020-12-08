class AddTopicToWebhookRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :webhook_requests, :topic, :string
  end
end
