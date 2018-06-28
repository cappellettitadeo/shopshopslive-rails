class Scrapers::Shopify::ResultVariant < Scrapers::Result
  def initialize(store, product, variant)
    @store = store
    @product = product
    @variant = variant
  end

  attr_reader :variant, :product, :store

  def available
    #inventory_quantity gonna be deprecated
    @available ||= variant.inventory_quantity.present? && variant.inventory_quantity > 0
  end

  def barcode
    @barcode ||= variant.barcode
  end

  def color
    position = nil
    product.options.each do |option|
      if option.name.downcase.eql? "color"
        position = option.position
        next
      end
    end
    @color = variant.send(:"option#{position}") unless position.nil?
  end

  def created_at
    @created_at ||= variant.created_at
  end

  def currency
    @currency ||= store.currency
  end

  def discounted
    @discounted = false
  end

  def inventory
    @inventory ||= variant.inventory_quantity
  end

  def name
    @name ||= variant.title
  end

  def original_price
    @original_price = variant.price
  end

  def product_id
    @product_id ||= variant.product_id
  end


  def price
    @price ||= variant.price
  end

  def source_id
    @source_id ||= store.source_id
  end

  def source_sku
    @source_sku ||= variant.sku
  end

  def size_id
    unless @size_id.present?
      position = nil
      size = nil
      product.options.each do |option|
        if option.name.downcase.eql? "size"
          position = option.position
          next
        end
      end
      size = variant.send(:"option#{position}") unless position.nil?
      unless size.nil?
        size_model = Size.where(size: size).first_or_create
        @size_id = size_model.id
      end
    end
    @size_id
  end

  def updated_at
    @updated_at ||= variant.updated_at
  end

  def weight
    @weight ||= variant.weight
  end

  def weight_unit
    @weight_unit ||= variant.weight_unit
  end

end