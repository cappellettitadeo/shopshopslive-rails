FactoryBot.define do
  ctr_product_id = rand(80000..999999)
  factory :product do
    sequence(:name) { |n| "Prada shoe #{n}" }
    sequence(:ctr_product_id) { |n| ctr_product_id + n }
    store
    vendor
    description 'Prada is the best'
    keywords ['prada', 'shoe']
    available true
    material 'Cotton'

    factory :product_with_variants do
      transient do
        variants_count 5
      end

      after(:create) do |product, evaluator|
        create_list(:product_variant, evaluator.variants_count, product: product)
      end
    end
  end
end
