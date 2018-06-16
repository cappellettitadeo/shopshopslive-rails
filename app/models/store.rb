class Store < ApplicationRecord
  has_many :products
  has_many :photos, as: :target, dependent: :destroy
  has_many :store_hours, dependent: :destroy
end
