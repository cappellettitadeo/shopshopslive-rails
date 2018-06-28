FactoryBot.define do
  factory :product do
    name 'Prada shoe'
    store
    vendor
    description 'Prada is the best'
    keywords ['prada', 'shoe']
    available true
    material 'Cotton'
  end
end
