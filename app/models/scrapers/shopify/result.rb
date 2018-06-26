class Scrapers::Smartlocating::Result < Scrapers::Result
  def initialize(product)
    @product = product
  end

  attr_reader :product

  def description
    @description ||= product[:description]
  end

  def variants
    # TODO
    product[:variants]
  end

  def photos
    # TODO
    product[:images]
  end
end
