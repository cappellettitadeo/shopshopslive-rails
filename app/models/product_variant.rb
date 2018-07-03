class ProductVariant < ApplicationRecord
  belongs_to :product
  belongs_to :size
  has_many :photos, as: :target, dependent: :destroy

  def self.create_from_shopify_variant(variant)
    product_variant = ProductVariant.new product: product, barcode: variant.barcode, color: variant.color,
                                         currency: variant.currency, inventory: variant.inventory, name: variant.name,
                                         original_price: variant.original_price, product_id: product.id,
                                         price: variant.price, source_id: variant.source_id, source_sku: variant.source_sku,
                                         size_id: variant.size_id, weight: variant.weight, weight_unit: variant.weight_unit
    product_variant.save
    product_variant
  end

  def self.update_from_shopify_variant(variant)

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
