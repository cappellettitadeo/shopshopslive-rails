class CreatePhotos < ActiveRecord::Migration[5.1]
  def change
    create_table :photos do |t|
      t.string :name
      t.string :file
      t.string :target_type
      t.integer :target_id
      t.string :photo_type
      t.integer :position
      t.integer :width
      t.integer :height

      t.timestamps
    end
    add_index :photos, [:target_type, :target_id]
    add_index :photos, :position
  end
end
