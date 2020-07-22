class LineItem < ApplicationRecord
  belongs_to :order
  belongs_to :product
  belongs_to :product_variant

  after_save :update_order
  after_destroy :update_order

  def name
    product.name if product
  end

  def price
    if product_variant
      product_variant.price
    elsif product
      product.price
    end
  end

  def size
    if product_variant
      product_variant.sizes
    end
  end

  def thumb_photo_url
    if product_variant && product
      product_variant.thumb_photo_url || product.thumb_photo_url
    end
  end

  def update_order
    order.save if order
  end

  def created_at_formatted
    created_at.strftime("%Y-%m-%d %H:%M:%S")
  end

  def updated_at_formatted
    updated_at.strftime("%Y-%m-%d %H:%M:%S")
  end
end
