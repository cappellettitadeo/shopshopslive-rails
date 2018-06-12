class Store < ApplicationRecord
	has_many :products
	has_many :photos, -> { where target_type: 'Store' }, dependent: :destroy
end
