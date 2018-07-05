class SyncQueue < ApplicationRecord
  belongs_to :target, polymorphic: true

  scope :products, -> { where(target_type: 'Product') }
end
