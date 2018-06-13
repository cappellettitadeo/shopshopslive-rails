# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180613015855) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "product_variants", force: :cascade do |t|
    t.string "name"
    t.integer "product_id"
    t.string "ctr_sku_id"
    t.integer "source_id"
    t.string "source_sku"
    t.float "original_price"
    t.float "price"
    t.boolean "discounted"
    t.string "color"
    t.integer "size_id"
    t.integer "inventory"
    t.string "currency"
    t.string "barcode"
    t.float "weight"
    t.string "weight_unit"
    t.boolean "available"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["source_id"], name: "index_product_variants_on_source_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.integer "store_id"
    t.integer "vendor_id"
    t.string "ctr_product_id"
    t.integer "source_id"
    t.integer "scraper_id"
    t.text "description"
    t.text "keywords", default: [], array: true
    t.string "material"
    t.boolean "available", default: true
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available"], name: "index_products_on_available"
    t.index ["source_id"], name: "index_products_on_source_id"
    t.index ["store_id"], name: "index_products_on_store_id"
    t.index ["vendor_id"], name: "index_products_on_vendor_id"
  end

  create_table "stores", force: :cascade do |t|
    t.string "name"
    t.string "ctr_store_id"
    t.text "description"
    t.string "website"
    t.string "phone"
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.float "latitude"
    t.float "longitude"
    t.float "local_rate"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
