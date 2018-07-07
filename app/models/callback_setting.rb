class CallbackSetting < ApplicationRecord
  scope :product, -> { where(callback_type: 'product') }
  scope :stores, -> { where(callback_type: 'store') }
  scope :vendor, -> { where(callback_type: 'vendor') }

  def bunch_update?
    mode == 'bunch'
  end

  def immediate_update?
    mode == 'immediate'
  end
end
