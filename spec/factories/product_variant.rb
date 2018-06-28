FactoryBot.define do
  factory :product_variant do
    name 'Prada shoe black'
    original_price 888
    price 888
    discounted false
    color 'black'
    size
    inventory 99
    currency 'usd'
    barcode '32291113341'
    weight 1.0
    weight_unit 'lb'
    available true
  end
end
