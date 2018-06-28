class Scrapers::Shopify::ResultPhoto < Scrapers::Result
  def initialize(store, product, variant)
    @store = store
    @product = product
    @variant = variant
  end

  attr_reader :variant, :product, :store

end

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