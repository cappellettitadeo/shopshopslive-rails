class Store < ApplicationRecord
  has_many :products
  has_many :photos, as: :target, dependent: :destroy
  has_many :store_hours, dependent: :destroy

  scope :active, -> { where(status: 'active') }
  scope :shopify, -> { where(source_type: 'shopify') }
end
