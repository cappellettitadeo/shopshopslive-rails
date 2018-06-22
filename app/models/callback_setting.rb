class CallbackSetting < ApplicationRecord
  scope :product, -> { where(callback_type: 'product') }

  def bunch_update?
    mode == 'bunch'
  end

  def immediate_update?
    mode == 'immediate'
  end
end
