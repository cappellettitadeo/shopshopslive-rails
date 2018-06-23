# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# 1. Create vendors
prada = Vendor.create name: 'Prada', description: 'Prada is the leading luxury brand in the world. We celebrate every precious moment in your life.',
                      phone: '+12135093215', street: '1 Broadway Street', city: 'New York', state: 'NY', zipcode: '10025'
gucci = Vendor.create name: 'Gucci', description: 'Gucci is even better thant Prada. We are more expensive.',
                      phone: '+13102345135', street: '21 Martin Street', unit_no: 'B', city: 'Los Angeles', state: 'CA', zipcode: '90017'
hm = Vendor.create name: 'H&M', description: 'We are H&M, cheap but great. Affordable fashion starts here.',
                      phone: '+12123321399', street: '1666 Main St.', unit_no: '#1', city: 'Las Vegas', state: 'NV', zipcode: '50012'

# 2. Create stores
dream_store = Store.create name: 'Dream Store', description: 'We help you to make your dream comes true.',
                           website: 'https://www.dreamstore.com', phone: '+13102342634', street: '2020 Portland St.', city: 'Los Angeles', unit_no: '20', zipcode: '91434',
                           latitude: 34.01895, longitude: -118.28369, local_rate: 9.25
west_field = Store.create name: 'Westfield', description: 'Westfield is the global shopping center. You can find all kinds of products here.',
                           website: 'https://www.westfield.com', phone: '+13131112143', street: '200 Camden St.', city: 'Los Angeles', zipcode: '90001',
                           latitude: 34.11349, longitude: -118.83224, local_rate: 9.25

# 3. Create Store Hours
day = Time.zone.today
open_time = Time.zone.local(day.year, day.month, day.day, 8, 0, 0)
close_time = Time.zone.local(day.year, day.month, day.day, 18, 0, 0)
(1..7).each do |index|
  dream_store.store_hours.create hour_type: 'regular', open_time: open_time, close_time: close_time, weekday: index
  west_field.store_hours.create hour_type: 'regular', open_time: open_time + 1.hour, close_time: close_time + 1.hour, weekday: index
end

# 4. Create categories
women = Category.create name: 'Women', level: 1
scarf = Category.create name: 'Scarf', level: 2, parent_id: women.id
top = Category.create name: 'Tops', level: 2, parent_id: women.id

# 5. Create sizes
m_size = Size.create size: 'm'
s_size = Size.create size: 's'
size_6 = Size.create country: 'us', size: '6'
size_7 = Size.create country: 'us', size: '7'


# 6. Create products
product_1 = Product.create name: 'Designer tops', vendor: prada, store: dream_store, source_id: '3215391104', keywords: ['prada', 'tops', 'designer tops'],
                           description: 'This top is the 2018 bestseller. Try it on!', material: 'Cotton', available: true
product_2 = Product.create name: 'Love Scarf', vendor: gucci, store: west_field, source_id: '3210531104', keywords: ['gucci', 'scarf', 'love theme'],
                           description: 'A beautiful scarf that fits all your occasions!', material: 'Silk', available: true
product_3 = Product.create name: 'High heel shoe', vendor: gucci, store: west_field, source_id: '3211531104', keywords: ['gucci', 'high heel', 'shoe'],
                           description: 'The 2018 high heel shoe is the most popular shoe from Gucci.', material: 'leather', available: true

# 7. Create product variants
pv_1_1 = product_1.product_variants.create name: 'Small size', source_id: '3215391104-1', source_sku: 'PARAD2018TOP', original_price: 450, price: 450,
                                         discounted: false, color: 'white', size: s_size, inventory: 100, currency: 'usd', barcode: '1234_white',
                                         weight: 0.8, weight_unit: 'lb', available: true
pv_1_2 = product_1.product_variants.create name: 'Medium size', source_id: '3215391104-2', source_sku: 'PARAD2018TOP2', original_price: 480, price: 480,
                                         discounted: false, color: 'white', size: m_size, inventory: 20, currency: 'usd', barcode: '1234_white1',
                                         weight: 0.9, weight_unit: 'lb', available: true
pv_2 = product_2.product_variants.create name: 'Scarf', source_id: '3210531104-1', source_sku: 'GUCCI2018SCARF', original_price: 700, price: 620,
                                         discounted: true, color: 'black', inventory: 10, currency: 'usd', barcode: '3222_scarf',
                                         weight: 1, weight_unit: 'lb', available: true
pv_3_1 = product_3.product_variants.create name: 'Shoe 6', source_id: '3211531104-1', source_sku: 'GUCCI2018SHOE', original_price: 880, price: 880,
                                         discounted: false, color: 'black', size: size_6, inventory: 29, currency: 'usd', barcode: '3439_shoe',
                                         weight: 2.4, weight_unit: 'lb', available: true
pv_3_2 = product_3.product_variants.create name: 'Shoe 7', source_id: '3211531104-2', source_sku: 'GUCCI2018SHOE1', original_price: 880, price: 880,
                                         discounted: false, color: 'black', size: size_7, inventory: 2, currency: 'usd', barcode: '3439_shoe1',
                                         weight: 2.5, weight_unit: 'lb', available: true
# 8. Create product photos
Photo.compose(product_1, 'product', 'https://images.yoox.com/12/12142143st_12_r.jpg')
Photo.compose(product_2, 'product', 'https://neimanmarcus.scene7.com/is/image/NeimanMarcus/NMD2X34_3N_m?&wid=456&height=570')
Photo.compose(product_2, 'product', 'https://neimanmarcus.scene7.com/is/image/NeimanMarcus/NMD2X34_41_m?&wid=456&height=570')
Photo.compose(product_3, 'product', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT19b0riQvEX1Ec9zDVwL8e7acdQx1oWSRJBia_jrMPNcPymaKB')
