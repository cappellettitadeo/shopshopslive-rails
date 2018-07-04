class AddCountryAndCurrencyToStore < ActiveRecord::Migration[5.1]
  def change
    add_column :stores, :country, :string
    add_column :stores, :currency, :string
  end
end
