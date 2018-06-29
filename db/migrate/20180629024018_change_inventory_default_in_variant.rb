class ChangeInventoryDefaultInVariant < ActiveRecord::Migration[5.1]
  def change
    change_column_default :product_variants, :inventory, 0
  end
end
