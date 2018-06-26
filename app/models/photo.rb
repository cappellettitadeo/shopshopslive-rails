class Photo < ApplicationRecord
  mount_uploader :file, PhotoUploader

  belongs_to :target, polymorphic: true
  before_create :set_filename

  def self.compose(target, photo_type, photo_url)
    photo = new(target: target)
    photo.photo_type = photo_type
    photo.remote_file_url = photo_url if photo_url
    photo.save
    photo
  end

  def set_filename
    self.name = file.filename
  end

  def url
    file.url
  end

  def thumb_url
    file.thumb.url
  end
end
