require 'shopify_app'

class Store < ApplicationRecord
  has_many :products
  has_many :photos, as: :target, dependent: :destroy
  has_many :store_hours, dependent: :destroy

  scope :active, -> { where(status: 'active') }
  scope :shopify, -> { where(source_type: 'shopify') }

  def self.create_store_from_shopify_shop(shopify_shop, myshopify_domain, access_token)
    store = Store.find_by_source_url(myshopify_domain)
    if store.nil?
      store = Store.new name: shopify_shop.name, description: '', country: shopify_shop.country_code,
                        website: shopify_shop.domain, phone: shopify_shop.phone, currency: shopify_shop.currency,
                        street: shopify_shop.address1, city: shopify_shop.city, state: shopify_shop.province,
                        unit_no: shopify_shop.address2, zipcode: shopify_shop.zip,
                        latitude: shopify_shop.latitude, longitude: shopify_shop.longitude, local_rate: nil,
                        source_url: myshopify_domain, source_token: access_token, source_id: shopify_shop.id, source_type: 'shopify'
      store.save
      store
    else
      update_store_from_shopify_shop(store, shopify_shop)
    end
  end

  def self.update_store_from_shopify_shop(store, shopify_shop)
    if store && shopify_shop
      store.name = shopify_shop.name
      store.country = shopify_shop.country_code
      store.website = shopify_shop.domain
      store.phone = shopify_shop.phone
      store.currency = shopify_shop.currency
      store.street = shopify_shop.address1
      store.city = shopify_shop.city
      store.state = shopify_shop.province
      store.unit_no = shopify_shop.address2
      store.zipcode = shopify_shop.zip
      store.latitude = shopify_shop.latitude
      store.longitude = shopify_shop.longitude
      store.save
      store
    end
  end

end
