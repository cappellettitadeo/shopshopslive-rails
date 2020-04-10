class CreatePhotos < ActiveRecord::Migration[5.1]
  def change
    create_table :photos do |t|
      t.string :name
      t.string :file
      t.string :target_type
      t.integer :target_id
      t.string :photo_type
      t.string :image_id
      t.integer :position
      t.integer :width
      t.integer :height
      t.integer :is_cover

      t.timestamps
    end
    add_index :photos, [:target_type, :target_id]
    add_index :photos, :position
    add_index :photos, :image_id
  end
end
