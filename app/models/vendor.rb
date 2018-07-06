class Vendor < ApplicationRecord
  has_many :products
  has_many :photos, as: :target, dependent: :destroy

  def logo_url
    logo = photos.logo.first
    logo.url if logo
  end
end
