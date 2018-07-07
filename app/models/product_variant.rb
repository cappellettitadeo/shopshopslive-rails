require 'shopify_app'
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
      billing_address = {
          address1: "Chestnut Street 92",
          address2: "Suite 300",
          city: "Louisville",
          country: "US",
          first_name: "shopshops",
          last_name: "shopshops inc.",
          phone: "555-625-1199",
          province: "KY",
          zip: "40202",
      }
      shipping_address = billing_address
      shipping_line = {
          handle: "shopify-Standard-10.00",
          price: "10.00",
          title: "Standard"
      }
      checkout = ShopifyAPI::Checkout.create(email: "customer@shopshops.com", line_items: [{requires_shipping: false, quantity: 1, variant_id: source_id}])
      #checkout.complete
      if complete?(checkout.token, shop_domain, access_token)
        self.inventory -= count
        self.save
      end
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
    binding.pry
    if response.code == 200
      true
    end
    false
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
      original_price: original_price,
      currency: currency
    }
  end
end
