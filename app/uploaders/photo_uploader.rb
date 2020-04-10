# encoding: utf-8

class PhotoUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  include Cloudinary::CarrierWave


  CarrierWave.configure do |config|
   config.cache_storage = :file
  end

  process :eager => true
  process :use_filename => true
  process :tags => ['product_photo']
  process resize_to_fit: [400, 400]

  # Create different versions of uploaded files:
  version :thumb do
    process :resize_to_fill => [240, 240]
  end

  # Add a white list of extensions which are allowed to be uploaded.
  def extension_white_list
    %w(jpg jpeg gif png)
  end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  def public_id
    dir + secure_token
  end

  def content_type_whitelist
    /image\//
  end

  def dir
    "#{Rails.env}/shopshops/#{model.target_id}/"
  end

  protected
  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.uuid)
  end
end
