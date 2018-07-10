class Vendor < ApplicationRecord
  has_many :products
  has_many :photos, as: :target, dependent: :destroy

  def self.sync_with_central_app
    vendors = CentralApp::Utils::Vendor.list_all
    if vendors.present?
      vendors.each do |vendor|
        local_vendor = Category.where(ctr_vendor_id: vendor[:id]).first_or_create
        local_vendor.name = vendor[:name_en]
        local_vendor.description = vendors[:description]
        local_vendor.save
      end
    end
  end

  def logo_url
    logo = photos.logo.first
    logo.url if logo
  end
end
