class CreateStores < ActiveRecord::Migration[5.1]
  def change
    create_table :stores do |t|
      t.string :name
      t.string :ctr_store_id
      t.text :description
      t.string :website
      t.string :phone
      t.string :street
      t.string :city
      t.string :state
      t.string :zipcode
      t.float :latitude
      t.float :longitude
      t.float :local_rate
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
