class ChangeColumnTypeInProductVariant < ActiveRecord::Migration[5.1]
  def change
    change_column :product_variants, :source_id, :string
    change_column :products, :source_id, :string
  end
end
