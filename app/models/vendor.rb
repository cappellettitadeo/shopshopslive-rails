class Vendor < ApplicationRecord
  has_many :products
  has_many :photos, as: :target, dependent: :destroy

  def self.sync_with_central_app
    vendors = CentralApp::Utils::Vendor.list_all
    if vendors.present?
      vendors.each do |vendor|
        local_vendor = Vendor.where(ctr_vendor_id: vendor[:id]).first_or_create
        local_vendor.name = vendor[:name]
        local_vendor.name_en = vendor[:name_en]
        local_vendor.description = vendor[:description]
        local_vendor.save
        begin
          Photo.compose(local_vendor, 'logo', vendor[:logo][:url]) if vendor[:logo][:url]
        rescue => e
          puts e
          next
        end
      end
    end
  end

  def logo_url
    logo = photos.logo.first
    logo.url if logo
  end
end
