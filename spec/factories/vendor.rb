FactoryBot.define do
  factory :vendor do
    name Faker::Company.name
    description 'A cool brand'
    phone Faker::PhoneNumber.phone_number
    street Faker::Address.street_address
    city Faker::Address.city
    state Faker::Address.state_abbr
    zipcode Faker::Address.zip_code
  end
end
