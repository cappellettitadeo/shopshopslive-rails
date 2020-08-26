class AddSourceIdToLineItems < ActiveRecord::Migration[5.1]
  def change
    add_column :line_items, :source_id, :string
  end
end
