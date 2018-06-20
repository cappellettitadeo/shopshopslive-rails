class CallbackSetting < ApplicationRecord
  scope :products, -> { where(callback_type: 'product') }

  def bunch_update?
    mode == 'bunch'
  end

  def immediate_update?
    mode == 'immediate'
  end
end
