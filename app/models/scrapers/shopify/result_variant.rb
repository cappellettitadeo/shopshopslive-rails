class Scrapers::Shopify::ResultVariant < Scrapers::Result
  def initialize(store, product, variant)
    @store = store
    @product = product
    @variant = variant
  end

  attr_reader :variant, :product, :store

  def available
    @available ||= variant[:inventory_quantity] > 0
  end

  def barcode
    @barcode ||= variant[:barcode]
  end

  def created_at
    @created_at ||= variant[:created_at]
  end

  def inventory
    @inventory ||= variant[:inventory_quantity]
  end

  def name
    @name ||= product[:title]
  end

  def product_id
    @product_id ||= product[:id]
  end


  def price
    @price ||= variant[:price]
  end

  def source_id

  end

  def updated_at
    @updated_at ||= variant[:updated_at]
  end



  t.string "ctr_sku_id"
  t.string "source_sku"
  t.float "original_price"
  t.boolean "discounted"
  t.string "color"
  t.integer "size_id"
  t.string "currency"
  t.float "weight"
  t.string "weight_unit"

end