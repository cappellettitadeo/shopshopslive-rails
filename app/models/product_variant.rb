require 'shopify_app'
require 'httparty'

class ProductVariant < ApplicationRecord
  belongs_to :product
  belongs_to :size
  has_many :photos, as: :target, dependent: :destroy
  has_many :options

  audited
  acts_as_paranoid

  after_update :sync_with_ctr_app

  def sync_with_ctr_app
    if inventory_changed?
      InventorySyncWorker.new.perform(id)
    end
  end

  def lock_inventory(count)
    product.sync_with_shopify
    self.reload
    if inventory >= count
      begin
        draft_order = ShopifyAPI::DraftOrder.create(email: ShopifyApp::Const::ACCOUNT_EMAIL,
                                                    shipping_address: ShopifyApp::Const::CUSTOMER_INFO,
                                                    line_items: [{quantity: count, variant_id: source_id}])
        if draft_order&.complete(payment_pending: true)
          self.inventory -= count
          self.save
        end
      rescue
        false
      end
    else
      false
    end
  end

  def complete?(check_token, shop, access_token)
    url = "https://#{shop}/admin/checkouts/#{check_token}/complete.json"
    puts check_token
    puts url
    puts access_token
    header = {
        "Content-type": "application/json",
        "X-Shopify-Access-Token": access_token,
    }

    response = HTTParty.post(url, headers: header)
    if response.code == 200
      true
    end
    false
  end

  def self.create_or_update_from_shopify_object(product, variant, source = 'product_listing')
    changed = false

    product_variant = ProductVariant.where(source_id: variant.source_id).first_or_create
    product_variant.product_id = product.id
    product_variant.available = variant.available
    product_variant.barcode = variant.barcode
    product_variant.color = variant.color
    product_variant.currency = variant.currency
    product_variant.inventory = variant.inventory
    product_variant.name = variant.name
    product_variant.original_price = variant.original_price
    product_variant.price = variant.price
    product_variant.source_id = variant.source_id
    product_variant.product_id = product.id
    product_variant.source_sku = variant.source_sku
    product_variant.size_id = variant.size_id
    product_variant.image_id = variant.image_id
    product_variant.weight = variant.weight
    product_variant.weight_unit = variant.weight_unit
    # Find or create the options
    shopify_ids = []
    if source == 'product'
      if variant.option1
        variant.options.each do |option|
          if option.values.include?(variant.option1)
            name = option.name.downcase
            id = option.id.to_s
            shopify_ids << id
            option = product_variant.options.where(source_id: id).first_or_initialize
            option.name = name
            option.value = variant.option1
            option.save
          end
        end
      end
      if variant.option2
        variant.options.each do |option|
          if option.values.include?(variant.option2)
            name = option.name.downcase
            id = option.id.to_s
            shopify_ids << id
            option = product_variant.options.where(source_id: id).first_or_initialize
            option.name = name
            option.value = variant.option2
            option.save
          end
        end
      end
      if variant.option3
        variant.options.each do |option|
          if option.values.include?(variant.option3)
            name = option.name.downcase
            id = option.id.to_s
            shopify_ids << id
            option = product_variant.options.where(source_id: id).first_or_initialize
            option.name = name
            option.value = variant.option3
            option.save
          end
        end
      end
    elsif source == 'product_listing'
      # backward compatible
      variant.options.each do |o|
        shopify_ids << o.option_id.to_s
        option = product_variant.options.where(source_id: o.option_id.to_s).first_or_initialize
        if option.id.nil?
          option.name = o.name
          option.value = o.value
          option.save
        end
      end
    end
    # Delete options if they are not in Shopify anymore
    product_variant.options.each do |op|
      unless shopify_ids.include?(op.source_id)
        op.destroy
      end
    end
    changed = true if product_variant.changed?
    product_variant.save
    changed
  end

  def sizes
    size.size if size
  end

  def count
    inventory
  end

  def currency_info
    {
        price: price,
        discounted: discounted,
        original_price: original_price,
        currency: currency
    }
  end
end
