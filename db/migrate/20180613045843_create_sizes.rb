class CreateSizes < ActiveRecord::Migration[5.1]
  def change
    create_table :sizes do |t|
      t.string :country
      t.string :size

      t.timestamps
    end
  end
end
