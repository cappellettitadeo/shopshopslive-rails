class Vendor < ApplicationRecord
  has_many :products
  has_many :photos, as: :target, dependent: :destroy

  def self.sync_with_central_app
    vendors = CentralApp::Utils::Vendor.list_all
    if vendors.present?
      vendors.each do |vendor|

      end
    end
  end

  def logo_url
    logo = photos.logo.first
    logo.url if logo
  end
end
