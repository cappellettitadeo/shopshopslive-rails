class Scrapers::Shopify::ResultPhoto < Scrapers::Result
  def initialize(store, product, photo)
    @store = store
    @product = product
    @photo = photo
  end

  attr_reader :photo, :product, :store

  def created_at
    @created_at ||= photo.created_at
  end

  def file
    #TODO
  end

  def name
    #TODO
  end

  def photo_type
    #TODO
  end

  def position
    @position ||= photo.position
  end

  def target_type
    #TODO
  end

  def target_id
    #TODO
  end

  def width
    @width ||= photo.width
  end

  def height
    @height ||= photo.height
  end

  def updated_at
    @updated_at ||= updated_at
  end

end
