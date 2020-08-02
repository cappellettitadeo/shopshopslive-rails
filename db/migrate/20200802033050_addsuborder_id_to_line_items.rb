class AddsuborderIdToLineItems < ActiveRecord::Migration[5.1]
  def change
    add_column :line_items, :suborder_id, :integer
    add_index :line_items, :suborder_id
  end
end
