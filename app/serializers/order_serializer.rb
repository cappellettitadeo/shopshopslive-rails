class OrderSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :status, :user_id, :refunded_at, :currency, :shipping_method, :shipping_fee, :subtotal_price,
    :total_price, :tax, :invoice_url, :confirmation_id, :draft, :source_id, :tracking_url, :shipping_status

  attribute :line_items do |o|
    LineItemSerializer.new(o.line_items).serializable_hash[:data]
  end

  attribute :shipping_address do |o|
    o.shipping_address.as_json
  end

  attribute :created_at do |o|
    o.created_at_formatted
  end

  attribute :updated_at do |o|
    o.updated_at_formatted
  end

  attribute :completed_at do |o|
    o.completed_at_formatted
  end
end