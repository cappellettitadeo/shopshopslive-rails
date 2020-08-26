class CreateShippingAddresses < ActiveRecord::Migration[5.1]
  def change
    create_table :shipping_addresses do |t|
      t.integer :user_id
      t.string :first_name
      t.string :last_name
      t.string :full_name
      t.string :address1
      t.string :address2
      t.string :phone
      t.string :city
      t.string :province
      t.string :country
      t.integer :source_id

      t.timestamps
    end
    add_index :shipping_addresses, :user_id
    add_index :shipping_addresses, :source_id
  end
end
