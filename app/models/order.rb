class Order < ApplicationRecord
  paginates_per 20

  belongs_to :user
  belongs_to :store
  belongs_to :shipping_address

  has_many :line_items

  scope :paid, -> { where(status: 'paid').order('created_at DESC') }

  before_create :generate_confirmation_id
  before_save :calculate_price

  STATUS = %w(submitted paid partially_paid refunded refunding fulfilled delivered closed)
  # 0: Master order
  # 1: Suborder - for different stores
  TYPE = [0, 1]

  def suborders
    order_type == 0 && Order.where(master_order_id: id)
  end

  def line_items
    if order_type == 0
      LineItem.where(order_id: id)
    elsif order_type == 1 
      LineItem.where(suborder_id: id)
    end
  end

  def master_order
    order_type == 1 && Order.find_by_id(master_order_id)
  end

  def complete
    if draft
      if suborders.present?
        suborders.each do |s|
          s.complete_draft
        end
      else
        self.complete_draft
      end
    else
      if suborders.present?
      else
      end
    end
  end

  def complete_draft
    res = ShopifyApp::Order.complete_draft_order(store, self)
    self.completed_at = res["completed_at"]
    self.status = 'paid'
    self.draft = false
    self.invoice_url = res["invoice_url"]
    # Replace draft order source_id with order source_id
    self.source_id = res["order_id"]
    self.save
  end

  def update_line_item(order)
    res = ShopifyApp::Order.get_order(order.store, order)
    res["line_items"].each do |li|
      pv = ProductVariant.where(source_id: li["variant_id"]).first
      if pv
        item = order.line_items.where(product_variant_id: pv.id, quantity: li["quantity"]).first
        item.source_id = li["id"].to_s
        item.save
      end
    end
  end

  def refund(line_items)
    if refundable?
      # 1. Get line_item id from Shopify order
      if suborders.present?
        suborders.each do |o|
          update_line_item(o)
        end
      else
        update_line_item(self)
      end
      # 2. Refund line_items
      suborder_ids = []
      line_items.each do |li|
        item = li[0]
        suborder_ids << item.suborder_id if item.suborder_id
      end
      if suborder_ids.uniq.size >= 1
        # If there is >= 1 suborder, use suborder for refund 
        suborder_ids.each do |id|
          items = line_items.select {|arr| arr[0].suborder_id == id }
          order = Order.find_by_id(id)
          res = ShopifyApp::Order.refund(order.store, order, items)
          # Update line item status
          update_line_items(res,line_items)
          update_order_status(order)
        end
      else
        res = ShopifyApp::Order.refund(store, self, line_items)
        update_line_items(res, line_items)
        update_order_status(self)
      end
    end
  end

  def update_order_status(order)
    order_li_size = order.line_items.size
    if order_li_size == order.line_items.where(status: 'refunded').size
      order.status = 'refunded' 
    elsif order_li_size > order.line_items.where(status: 'refunded').size
      order.status = 'partially_refunded' 
    end
    order.save
  end

  def update_line_items(res, line_items)
    # Update line item status
    res['refund_line_items'].each do |ri|
      li = line_items.where(source_id: ri['line_item_id'].to_s).first
      li.status = 'refund'
      li.source_refund_id = ri['id']
      li.save
    end
  end

  def refundable?
    %w(paid partially_paid fulfilled delivered).include?(status)
  end

  def sync_with_shopify
    ShopifyApp::Order.get_order(store, self)
  end

  def process_order_with_shopify(order)
    if order.draft
      res = ShopifyApp::Order.create_draft_order(order.store, order)
      self.status = 'submitted'
    else
      res = ShopifyApp::Order.create_order(order.store, order)
      self.status = 'paid'
    end
    self.source_id = res['id']
    self.currency = 'USD'
    self.tax = res['total_tax']
    self.total_price = res['total_price']
    self.subtotal_price = res['subtotal_price']
    self.shipping_method = ''
    self.save
  end

  def generate_order_with_shopify
    # 1. If there are suborders, create orders on shopify for each suborder
    if suborders.present?
      suborders.each do |s|
        process_order_with_shopify(s)
      end
      self.status = draft ? 'submitted' : 'paid' 
      self.save
    else
      process_order_with_shopify(self)
    end
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