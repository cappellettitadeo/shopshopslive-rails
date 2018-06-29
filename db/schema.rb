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

ActiveRecord::Schema.define(version: 20180629082208) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "api_keys", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.string "auth_token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auth_token"], name: "index_api_keys_on_auth_token"
    t.index ["key"], name: "index_api_keys_on_key"
  end

  create_table "callback_settings", force: :cascade do |t|
    t.string "callback_type"
    t.string "url"
    t.string "mode"
    t.integer "bunch_size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "ctr_category_id"
    t.integer "level"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "categories_products", force: :cascade do |t|
    t.integer "product_id"
    t.integer "category_id"
    t.index ["category_id"], name: "index_categories_products_on_category_id"
    t.index ["product_id"], name: "index_categories_products_on_product_id"
  end

  create_table "photos", force: :cascade do |t|
    t.string "name"
    t.string "file"
    t.string "target_type"
    t.integer "target_id"
    t.string "photo_type"
    t.integer "position"
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["position"], name: "index_photos_on_position"
    t.index ["target_type", "target_id"], name: "index_photos_on_target_type_and_target_id"
  end

  create_table "product_variants", force: :cascade do |t|
    t.string "name"
    t.integer "product_id"
    t.string "ctr_sku_id"
    t.string "source_id"
    t.string "source_sku"
    t.float "original_price"
    t.float "price"
    t.boolean "discounted"
    t.string "color"
    t.integer "size_id"
    t.integer "inventory", default: 0
    t.string "currency"
    t.string "barcode"
    t.float "weight"
    t.string "weight_unit"
    t.boolean "available"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ctr_sku_id"], name: "index_product_variants_on_ctr_sku_id"
    t.index ["product_id"], name: "index_product_variants_on_product_id"
    t.index ["source_id"], name: "index_product_variants_on_source_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.integer "store_id"
    t.integer "vendor_id"
    t.string "ctr_product_id"
    t.string "source_id"
    t.integer "scraper_id"
    t.text "description"
    t.text "keywords", default: [], array: true
    t.string "material"
    t.boolean "available", default: true
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["available"], name: "index_products_on_available"
    t.index ["ctr_product_id"], name: "index_products_on_ctr_product_id"
    t.index ["source_id"], name: "index_products_on_source_id"
    t.index ["store_id"], name: "index_products_on_store_id"
    t.index ["vendor_id"], name: "index_products_on_vendor_id"
  end

  create_table "scrapers", force: :cascade do |t|
    t.string "source"
    t.string "source_type"
    t.string "status"
    t.string "url"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source"], name: "index_scrapers_on_source"
  end

  create_table "sizes", force: :cascade do |t|
    t.string "country"
    t.string "size"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "store_hours", force: :cascade do |t|
    t.integer "store_id"
    t.string "hour_type"
    t.datetime "open_time"
    t.datetime "close_time"
    t.integer "weekday"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["store_id"], name: "index_store_hours_on_store_id"
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
    t.string "unit_no"
    t.string "source_type"
    t.string "source_id"
    t.string "source_token"
    t.string "source_url"
    t.string "status", default: "active"
    t.index ["ctr_store_id"], name: "index_stores_on_ctr_store_id"
  end

  create_table "sync_logs", force: :cascade do |t|
    t.string "method"
    t.string "url"
    t.integer "status_code"
    t.string "target_type"
    t.text "target_ids", default: [], array: true
    t.text "raw_request"
    t.text "raw_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sync_queues", force: :cascade do |t|
    t.string "target_type"
    t.integer "target_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name"
    t.integer "ctr_vendor_id"
    t.text "description"
    t.string "phone"
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unit_no"
    t.index ["ctr_vendor_id"], name: "index_vendors_on_ctr_vendor_id"
  end

end
