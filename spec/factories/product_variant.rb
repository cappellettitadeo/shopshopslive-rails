FactoryBot.define do
  price = rand(100..1000)
  inventory = rand(2..99)
  barcode = rand(10000..999999)
  ctr_sku_id = rand(80000..999999)
  factory :product_variant do
    name 'Prada shoe black'
    sequence(:original_price) { |n| price + n }
    sequence(:price) { |n| price + n }
    sequence(:ctr_sku_id) { |n| ctr_sku_id + n }
    discounted false
    color ['black', 'red', 'blue'].sample
    size
    inventory inventory
    currency 'usd'
    sequence(:barcode) { |n| barcode + n }
    weight 1.0
    weight_unit 'lb'
    available true
  end
end
