class AddPasswordToApiKey < ActiveRecord::Migration[5.1]
  def change
    add_column :api_keys, :encrypted_password, :string, default: "", null: false
  end
end
