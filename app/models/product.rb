class Product < ApplicationRecord
	has_many :photos, as: :target, dependent: :destroy
	has_many :product_variants, dependent: :destroy
  has_and_belongs_to_many :categories
  belongs_to :store
  belongs_to :vendor
  belongs_to :scraper

  def brandName
    vendor.name if vendor
  end

  def category_1st
    categories.level_1.first
  end

  def category_1st_name
    cat_1 = category_1st
    cat_1.name if cat_1
  end

  def category_1st_id
    cat_1 = category_1st
    cat_1.id if cat_1
  end

  def category_2nd
    categories.level_2.first
  end

  def category_2nd_name
    cat_2 = category_2nd
    cat_2.name if cat_2
  end

  def category_2nd_id
    cat_2 = category_2nd
    cat_2.id if cat_2
  end

  def ctr_vendor_id
    vendor.ctr_vendor_id if vendor
  end
end
