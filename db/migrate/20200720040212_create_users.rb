class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :full_name
      t.integer :gender
      t.string :email
      t.string :phone
      t.string :slug

      t.timestamps
    end
    add_index :users, :email
    add_index :users, :phone
  end
end
