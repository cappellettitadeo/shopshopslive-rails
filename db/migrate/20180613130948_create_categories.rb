class CreateCategories < ActiveRecord::Migration[5.1]
  def change
    create_table :categories do |t|
      t.string :name
      t.string :ctr_category_id
      t.integer :level
      t.integer :parent_id

      t.timestamps
    end
  end
end
