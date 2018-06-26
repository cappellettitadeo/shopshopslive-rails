class ChangeColumnNameInVendor < ActiveRecord::Migration[5.1]
  def change
    rename_column :vendors, :destription, :description
  end
end
