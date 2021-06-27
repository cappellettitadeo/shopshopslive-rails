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

ActiveRecord::Schema.define(version: 20210627131419) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_keys", force: :cascade do |t|
    t.string "name"
    t.string "key"
    t.string "auth_token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.index ["auth_token"], name: "index_api_keys_on_auth_token"
    t.index ["key"], name: "index_api_keys_on_key"
  end

  create_table "audits", force: :cascade do |t|
    t.integer "auditable_id"
    t.string "auditable_type"
    t.integer "associated_id"
    t.string "associated_type"
    t.integer "user_id"
    t.string "user_type"
    t.string "username"
    t.string "action"
    t.text "audited_changes"
    t.integer "version", default: 0
    t.string "comment"
    t.string "remote_address"
    t.string "request_uuid"
    t.datetime "created_at"
    t.index ["associated_type", "associated_id"], name: "associated_index"
    t.index ["auditable_type", "auditable_id"], name: "auditable_index"
    t.index ["created_at"], name: "index_audits_on_created_at"
    t.index ["request_uuid"], name: "index_audits_on_request_uuid"
    t.index ["user_id", "user_type"], name: "user_index"
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
    t.string "name_en"
    t.index ["name_en"], name: "index_categories_on_name_en"
  end

  create_table "categories_products", force: :cascade do |t|
    t.integer "product_id"
    t.integer "category_id"
    t.index ["category_id"], name: "index_categories_products_on_category_id"
    t.index ["product_id"], name: "index_categories_products_on_product_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.integer "product_id"
    t.integer "product_variant_id"
    t.integer "order_id"
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "price"
    t.string "name"
    t.string "color"
    t.integer "size_id"
    t.integer "suborder_id"
    t.string "source_id"
    t.string "status"
    t.string "source_refund_id"
    t.index ["suborder_id"], name: "index_line_items_on_suborder_id"
  end

  create_table "options", force: :cascade do |t|
    t.integer "product_variant_id"
    t.string "source_id"
    t.string "name"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_variant_id"], name: "index_options_on_product_variant_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "user_id"
    t.string "status"
    t.datetime "completed_at"
    t.datetime "refunded_at"
    t.string "currency"
    t.string "shipping_method"
    t.string "full_address"
    t.string "refund_id"
    t.float "shipping_fee"
    t.float "subtotal_price"
    t.float "total_price"
    t.float "tax"
    t.string "invoice_url"
    t.integer "shipping_address_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_id"
    t.integer "order_type", default: 0
    t.integer "master_order_id"
    t.integer "store_id"
    t.boolean "draft", default: false
    t.string "source_id"
    t.string "ctr_order_id"
    t.string "tracking_url"
    t.string "shipping_status"
    t.string "tracking_no"
    t.string "tracking_company"
    t.index ["confirmation_id"], name: "index_orders_on_confirmation_id"
    t.index ["master_order_id"], name: "index_orders_on_master_order_id"
    t.index ["status"], name: "index_orders_on_status"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "photos", force: :cascade do |t|
    t.string "name"
    t.string "file"
    t.string "target_type"
    t.integer "target_id"
    t.string "photo_type"
    t.string "image_id"
    t.integer "position"
    t.integer "width"
    t.integer "height"
    t.integer "is_cover"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source_url"
    t.index ["image_id"], name: "index_photos_on_image_id"
    t.index ["position"], name: "index_photos_on_position"
    t.index ["source_url"], name: "index_photos_on_source_url"
    t.index ["target_type", "target_id"], name: "index_photos_on_target_type_and_target_id"
  end

  create_table "product_scrapers", force: :cascade do |t|
    t.string "source"
    t.string "source_type"
    t.string "status"
    t.string "url"
    t.text "error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["source"], name: "index_product_scrapers_on_source"
  end

  create_table "product_variants", force: :cascade do |t|
    t.string "name"
    t.integer "product_id"
    t.string "ctr_sku_id"
    t.string "image_id"
    t.string "source_id"
    t.string "source_sku"
    t.float "original_price"
    t.float "price"
    t.boolean "discounted", default: false
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
    t.index ["available"], name: "index_product_variants_on_available"
    t.index ["ctr_sku_id"], name: "index_product_variants_on_ctr_sku_id"
    t.index ["image_id"], name: "index_product_variants_on_image_id"
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
    t.datetime "expires_at"
    t.datetime "delisted_at"
    t.datetime "relisted_at"
    t.string "product_type"
    t.index ["available"], name: "index_products_on_available"
    t.index ["ctr_product_id"], name: "index_products_on_ctr_product_id"
    t.index ["expires_at"], name: "index_products_on_expires_at"
    t.index ["name"], name: "index_products_on_name"
    t.index ["source_id"], name: "index_products_on_source_id"
    t.index ["store_id"], name: "index_products_on_store_id"
    t.index ["vendor_id"], name: "index_products_on_vendor_id"
  end

  create_table "shipping_addresses", force: :cascade do |t|
    t.integer "user_id"
    t.string "first_name"
    t.string "last_name"
    t.string "full_name"
    t.string "address1"
    t.string "address2"
    t.string "phone"
    t.string "city"
    t.string "province"
    t.string "country"
    t.integer "source_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "zip"
    t.index ["source_id"], name: "index_shipping_addresses_on_source_id"
    t.index ["user_id"], name: "index_shipping_addresses_on_user_id"
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
    t.string "country"
    t.string "currency"
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

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "full_name"
    t.integer "gender"
    t.string "email"
    t.string "phone"
    t.string "slug"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "source_id"
    t.string "ctr_user_id"
    t.index ["email"], name: "index_users_on_email"
    t.index ["phone"], name: "index_users_on_phone"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name"
    t.string "ctr_vendor_id"
    t.text "description"
    t.string "phone"
    t.string "street"
    t.string "city"
    t.string "state"
    t.string "zipcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "unit_no"
    t.string "name_en"
    t.index ["ctr_vendor_id"], name: "index_vendors_on_ctr_vendor_id"
    t.index ["name_en"], name: "index_vendors_on_name_en"
  end

  create_table "webhook_requests", force: :cascade do |t|
    t.jsonb "res"
    t.string "source"
    t.string "domain"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "topic"
    t.index ["domain"], name: "index_webhook_requests_on_domain"
  end

end
