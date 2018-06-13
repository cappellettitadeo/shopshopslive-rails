class Store < ApplicationRecord
	has_many :products
	has_many :photos, as: :target, dependent: :destroy
end
