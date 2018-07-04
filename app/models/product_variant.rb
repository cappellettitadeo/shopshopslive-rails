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

  def self.create_from_shopify_variant(product, variant)
    if ProductVariant.find_by_source_id(variant.source_id).nil?
      product_variant = ProductVariant.new product: product, barcode: variant.barcode, color: variant.color,
                                           currency: variant.currency, inventory: variant.inventory, name: variant.name,
                                           original_price: variant.original_price, product_id: product.id,
                                           price: variant.price, source_id: variant.source_id, source_sku: variant.source_sku,
                                           size_id: variant.size_id, weight: variant.weight, weight_unit: variant.weight_unit
      product_variant.save
      product_variant
    else
      update_from_shopify_variant(product, variant)
    end
  end

  def self.update_from_shopify_variant(product, variant)
    product_variant = ProductVariant.find_by_source_id(variant.source_id)
    if product_variant
      product_variant.barcode = variant.barcode
      product_variant.color = variant.color
      product_variant.currency = variant.currency
      product_variant.inventory = variant.inventory
      product_variant.name = variant.name
      product_variant.price = variant.price
      product_variant.source_sku = variant.source_sku
      product_variant.size_id = variant.size_id
      product_variant.weight = variant.weight
      product_variant.weight_unit = variant.weight_unit

      product_variant.save
      product_variant
    else
      create_from_shopify_variant(product, variant)
    end
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
