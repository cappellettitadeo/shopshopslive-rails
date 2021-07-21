class AddUniqueToSourceId < ActiveRecord::Migration[5.1]
  def change
    remove_index :products, :source_id
    add_index :products, :source_id, unique: true
  end
end
