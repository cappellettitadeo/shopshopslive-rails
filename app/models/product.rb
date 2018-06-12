class Product < ApplicationRecord
	has_many :photos, -> { where target_type: 'Product' }, dependent: :destroy
	has_many :skus, dependent: :destroy
  has_and_belongs_to_many :categories
  belongs_to :store
  belongs_to :vendor
  belongs_to :scraper
end
