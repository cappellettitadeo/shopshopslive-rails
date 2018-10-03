class CreateOptions < ActiveRecord::Migration[5.1]
  def change
    create_table :options do |t|
      t.integer :product_variant_id
      t.string :source_id
      t.string :name
      t.string :value

      t.timestamps
    end
    add_index :options, :product_variant_id
  end
end
