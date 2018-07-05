class ProductVariant < ApplicationRecord
  belongs_to :product
  belongs_to :size
  has_many :photos, as: :target, dependent: :destroy

  def lock_inventory(count)
    if inventory >= count
      self.inventory -= count
      self.save
    else
      false
    end
  end

  def self.create_or_update_from_shopify_object(product, variant)
    changed = false

    product_variant = ProductVariant.where(source_id: variant.source_id, product_id: product.id).first_or_create
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
