class ChangeCtrVendorIdType < ActiveRecord::Migration[5.1]
  def change
    change_column :vendors, :ctr_vendor_id, :string
  end
end
