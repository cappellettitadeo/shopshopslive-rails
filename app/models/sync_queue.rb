class SyncQueue < ApplicationRecord
  belongs_to :target, polymorphic: true

  validates_presence_of :target_type, :target_id

  scope :products, -> { where(target_type: 'Product') }
end
