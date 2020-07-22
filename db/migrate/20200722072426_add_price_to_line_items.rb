class AddPriceToLineItems < ActiveRecord::Migration[5.1]
  def change
    add_column :line_items, :price, :float
    add_column :line_items, :name, :string
    add_column :line_items, :color, :string
    add_column :line_items, :size_id, :integer
  end
end
