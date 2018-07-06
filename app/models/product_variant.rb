require 'shopify_app/utils'
require 'httparty'

class ProductVariant < ApplicationRecord
  belongs_to :product
  belongs_to :size
  has_many :photos, as: :target, dependent: :destroy

  def lock_inventory(count)
    if inventory >= count

      store = Store.first
      shop_domain = store.source_url
      access_token = store.source_token
      ShopifyApp::Utils.instantiate_session(shop_domain, access_token)
      binding.pry
      checkout = ShopifyAPI::Checkout.create(line_items: [{quantity:1, variant_id: source_id}])
      checkout.complete
      if checkout
        self.inventory -= count
        self.save
      end

    else
      false
    end
  end

  def complete(check_token, shop, access_token)
    url = "https://#{shop}/admin/checkouts/#{check_token}/complete"
    header = {
        "Content-type": "application/json",
        "X-Shopify-Access-Token": access_token
    }

    response = HTTParty.post(url, header: header)
    binding.pry
    if response.code == 200
      response['access_token']
    end
  end

  def self.create_or_update_from_shopify_object(product, variant)
    changed = false

    product_variant = ProductVariant.where(source_id: variant.source_id, product_id: product.id).first_or_create
    product_variant.available = variant.available
    product_variant.barcode = variant.barcode
    product_variant.color = variant.color
    product_variant.currency = variant.currency
    product_variant.inventory = variant.inventory
    product_variant.name = variant.name
    product_variant.original_price = variant.original_price
    product_variant.price = variant.price
    product_variant.source_sku = variant.source_sku
    product_variant.size_id = variant.size_id
    product_variant.weight = variant.weight
    product_variant.weight_unit = variant.weight_unit
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
      originalPrice: original_price,
      currency: currency
    }
  end
end
