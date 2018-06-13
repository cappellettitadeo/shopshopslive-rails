class ProductVariant < ApplicationRecord
  belongs_to :product
  belongs_to :size
  has_many :photos, as: :target, dependent: :destroy
end
