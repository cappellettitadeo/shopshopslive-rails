class CreateScrapers < ActiveRecord::Migration[5.1]
  def change
    create_table :scrapers do |t|
      t.string :source
      t.string :source_type
      t.string :status
      t.string :url
      t.text :error

      t.timestamps
    end
    add_index :scrapers, :source
  end
end
