class AddUnitNoToStore < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :unit_no, :string
    add_column :vendors, :unit_no, :string
  end
end
