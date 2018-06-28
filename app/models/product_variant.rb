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
