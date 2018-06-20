class SyncQueue < ApplicationRecord
  scope :products, -> { where(target_type: 'Product') }
end
