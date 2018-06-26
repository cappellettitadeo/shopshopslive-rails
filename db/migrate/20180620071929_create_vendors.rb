class CreateVendors < ActiveRecord::Migration[5.1]
  def change
    create_table :vendors do |t|
      t.string :name
      t.integer :ctr_vendor_id
      t.text :destription
      t.string :phone
      t.string :street
      t.string :city
      t.string :state
      t.string :zipcode
      t.timestamps
    end
  end
end
