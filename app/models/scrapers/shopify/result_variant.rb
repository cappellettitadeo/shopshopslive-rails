class Scrapers::Shopify::ResultVariant < Scrapers::Result
  def initialize(store, product, variant)
    @store = store
    @product = product
    @variant = variant
  end

  attr_reader :variant, :product, :store

  def available
    #TODO inventory_quantity gonna be deprecated
    @available ||= variant.inventory_quantity && variant.inventory_quantity > 0
  end

  def barcode
    @barcode ||= variant.barcode
  end

  def color
    unless @color
      if variant.option_values.present?
        variant.option_values.each do |option|
          if option.name.downcase == "color"
            @color = option.value
            break
          end
        end
      else
        position = nil
        product.options.each do |option|
          if option.name.downcase == "color"
            position = option.position
            break
          end
        end
        @color = variant.send(:"option#{position}") if position
      end
    end
    @color
  end

  def created_at
    @created_at ||= variant.created_at
  end

  def currency
    @currency ||= store.currency
  end

  def discounted
    @discounted = variant.price > variant.compare_at_price.to_f ? true : false
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
    product.id
  end

  def price
    @price ||= variant.price
  end

  def source_id
    @source_id ||= variant.id
  end

  def source_sku
    @source_sku ||= variant.sku
  end

  def size_id
    unless @size_id
      position = nil
      size = nil
      if variant.option_values.present?
        variant.option_values.each do |option|
          if option.name.downcase == "size"
            size = option.value
            break
          end
        end
      else
        product.options.each do |option|
          if option.name.downcase == "size"
            position = option.position
            break
          end
        end
        size = variant.send(:"option#{position}") if position
      end

      if size
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
