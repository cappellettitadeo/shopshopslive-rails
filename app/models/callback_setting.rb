class CallbackSetting < ApplicationRecord
  scope :products, -> { where(callback_type: 'product') }
end
