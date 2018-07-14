class ChangeDiscountedDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default :product_variants, :discounted, false
  end
end
