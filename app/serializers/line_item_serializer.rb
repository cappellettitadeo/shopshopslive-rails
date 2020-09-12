class LineItemSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :product_id, :ctr_sku_id, :product_variant_id, :order_id, :quantity, :price, :name, :color

  attribute :created_at do |l|
    l.created_at_formatted
  end

  attribute :updated_at do |l|
    l.updated_at_formatted
  end
end
