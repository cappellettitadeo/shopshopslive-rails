class Product < ApplicationRecord
	has_many :photos, as: :target, dependent: :destroy
	has_many :product_variants, dependent: :destroy
  has_and_belongs_to_many :categories
  belongs_to :store
  belongs_to :vendor
  belongs_to :scraper
end
