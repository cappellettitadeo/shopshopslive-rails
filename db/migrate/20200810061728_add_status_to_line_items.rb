class AddStatusToLineItems < ActiveRecord::Migration[5.1]
  def change
    add_column :line_items, :status, :string
    add_column :line_items, :source_refund_id, :string
  end
end
