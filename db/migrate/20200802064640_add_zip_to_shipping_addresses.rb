class AddZipToShippingAddresses < ActiveRecord::Migration[5.1]
  def change
    add_column :shipping_addresses, :zip, :string
  end
end
