class ProductVariant < ApplicationRecord
  belongs_to :product
	has_many :photos, -> { where target_type: 'ProductVariant' }, dependent: :destroy
end
