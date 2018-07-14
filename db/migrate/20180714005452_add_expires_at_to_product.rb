class AddExpiresAtToProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :expires_at, :datetime
    add_column :products, :delisted_at, :datetime
    add_column :products, :relisted_at, :datetime

    add_index :products, :expires_at
    add_index :product_variants, :available
  end
end
