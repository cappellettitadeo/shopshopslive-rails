class AddNameEnToVendor < ActiveRecord::Migration[5.1]
  def change
    add_column :vendors, :name_en, :string
  end
end
