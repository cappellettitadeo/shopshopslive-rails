class ProductVariant < ApplicationRecord
  belongs_to :product
  belongs_to :size
  has_many :photos, -> { where target_type: 'ProductVariant' }, dependent: :destroy
end
