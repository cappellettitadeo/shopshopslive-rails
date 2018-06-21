class CreateApiKeys < ActiveRecord::Migration[5.1]
  def change
    create_table :api_keys do |t|
      t.string :name
      t.string :key
      t.string :auth_token
      t.datetime :expires_at

      t.timestamps
    end
    add_index :api_keys, :key
    add_index :api_keys, :auth_token
  end
end
