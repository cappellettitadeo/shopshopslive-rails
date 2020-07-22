class Order < ApplicationRecord
  belongs_to :user
  belongs_to :shipping_address

  has_many :line_items

  scope :paid, -> { where(status: 'paid').order('created_at DESC') }

  before_create :generate_confirmation_id
  before_save :calculate_price

  STATUS = %w(submitted paid partially_paid refunded refunding fulfilled delivered closed)

  def generate_order_with_shopify
    # 1. Request Shopify create order API
    self.status = 'paid'
    self.currency = 'USD'
    self.shipping_method = ''
    self.completed_at = Time.now
    self.save
  end

  def refundable?
    %w[paid partially_paid fulfilled delivered closed].include?(status)
  end

  def non_refundable_reason
    if %w[submitted].include?(status)
      '订单未完成'
    elsif %w[refunding].include?(status)
      '退款申请已提交'
    elsif %w[refunded].include?(status) && refund_id
      '订单已退款'
    end
  end

  def total_price_in_cents
    (total_price * 100).round(0)
  end

  def created_at_formatted
    created_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  def updated_at_formatted
    updated_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  def completed_at_formatted
    completed_at.strftime("%Y-%m-%d %H:%M:%S") if completed_at
  end

  def user_name
    user.nickname if user
  end

  def user_slug
    user.slug if user
  end

  def user_city
    user.city if user
  end

  def full_address
    shipping_address.address_with_name if shipping_address
  end

  def confirm_payment(wpay_id, time_end = Time.now)
  end

  def generate_confirmation_id
    con_id = nil
    loop do
      date = Time.now.strftime("%Y%m%d%H%M%S%2N")
      con_id = 'S' + date + SecureRandom.random_number(100000..999999).to_s
      break con_id unless Order.find_by_confirmation_id(con_id)
    end
    self.confirmation_id = con_id
  end

  def calculate_price
    price = line_items.joins(:product_variant).sum("product_variants.price * line_items.quantity")
    self.subtotal_price = price
    self.total_price = price + shipping_fee.to_f + tax.to_f
  end

  private

  def refund_response_err(res)
    if res['return_code'] == 'FAIL'
      return "return_code: #{res['return_code']}; return_msg: #{res['return_msg']}"
    end

    return unless res['err_code'] && res['err_code_des']

    "err_code: #{res['err_code']}; err_code_des: #{res['err_code_des']}"
  end
end
