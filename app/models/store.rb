class Store < ApplicationRecord
  has_many :products
  has_many :photos, as: :target, dependent: :destroy
  has_many :store_hours, dependent: :destroy

  scope :active, -> { where(status: 'active') }
  scope :shopify, -> { where(source_type: 'shopify') }

  def self.create_store_from_shopify_shop(shopify_shop)
    store = Store.new name: shopify_shop.name, description: '', country: shopify_shop.country_code,
                      website: shopify_shop.domain, phone: shopify_shop.phone, currency: shopify_shop.currency,
                      street: shopify_shop.address1, city: shopify_shop.city, state: shopify_shop.province,
                      unit_no: shopify_shop.address2, zipcode: shopify_shop.zip,
                      latitude: shopify_shop.latitude, longitude: shopify_shop.longitude, local_rate: nil,
                      source_url: myshopify_domain, source_token: access_token, source_id: shopify_shop.id, source_type: 'shopify'
    store.new
    store
  end

  def self.update_store_from_shopify_shop(store, updated_shop)
    if store && updated_shop
      Rails.logger.debug updated_shop
      store.name = updated_shop.name
      store.country = updated_shop.country_code
      store.website = updated_shop.domain
      store.phone = updated_shop.phone
      store.currency = updated_shop.currency
      store.street = updated_shop.address1
      store.city = updated_shop.city
      store.state = updated_shop.province
      store.unit_no = updated_shop.address2
      store.zipcode = updated_shop.zip
      store.latitude = updated_shop.latitude
      store.longitude = updated_shop.longitude
      store.save
    end
    Rails.logger.debug store
  end
end
