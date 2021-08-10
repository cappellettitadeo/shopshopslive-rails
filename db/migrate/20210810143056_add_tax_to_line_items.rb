class AddTaxToLineItems < ActiveRecord::Migration[5.1]
  def change
    add_column :line_items, :tax, :float
  end
end
