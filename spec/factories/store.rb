FactoryBot.define do
  factory :store do
    name Faker::Company.name
    description 'A cool store'
    website Faker::Internet.url
    phone Faker::PhoneNumber.phone_number
    street Faker::Address.street_address
    city Faker::Address.city
    state Faker::Address.state_abbr
    zipcode Faker::Address.zip_code
    #country 'us'
    #currency 'usd'
    latitude Faker::Address.latitude
    longitude Faker::Address.longitude
    local_rate 9.5
  end
end
