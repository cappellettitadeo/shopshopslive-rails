class RenameScraperTable < ActiveRecord::Migration[5.1]
  def change
    rename_table :scrapers, :product_scrapers
  end
end
