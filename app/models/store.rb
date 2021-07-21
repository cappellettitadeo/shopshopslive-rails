require 'shopify_app'

class Store < ApplicationRecord
  has_many :products
  has_many :orders
  has_many :photos, as: :target, dependent: :destroy
  has_many :store_hours, dependent: :destroy

  scope :active, -> { where(status: 'active') }
  scope :shopify, -> { where(source_type: 'shopify') }

  audited
  acts_as_paranoid

  def self.create_or_update_from_shopify_shop(shopify_shop, access_token = nil)
    # changed is a flag to indicate whether the product or it's associations has been changed
    # and need to be synced with the central system
    changed = false
    store = Store.where(source_url: shopify_shop.myshopify_domain).first_or_initialize
    store.name = shopify_shop.name
    store.description = ''
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
    store.source_url = shopify_shop.myshopify_domain
    store.source_id = shopify_shop.id
    store.source_type = 'shopify'
    store.status = 'active'
    store.source_token = access_token if access_token

    # 1.1 Check if any field has changed when store already exists in DB
    changed = true if store.changed?
    store.save

    [store, changed]
  end

  def self.sync_with_central_app
    stores = CentralApp::Utils::StoreC.list_all
    if stores.present?
      stores.each do |str|
        str = Category.where(ctr_store_id: str[:id]).first_or_create
        str.name = str[:name]
        str.website = str[:website]
        str.street = str[:address]
        str.city = str[:cityName]
        str.state = str[:state]
        str.latitude = str[:lat]
        str.longitude = str[:lng]
        str.save
        str[:photos].each do |url|
          Photo.compose(str, nil, url)
        end
      end
    end
  end

  def lat
    latitude
  end

  def lng
    longitude
  end
end
