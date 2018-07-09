class Photo < ApplicationRecord
  mount_uploader :file, PhotoUploader

  scope :logo, -> { where(photo_type: 'logo') }

  belongs_to :target, polymorphic: true
  before_create :set_filename

  def self.compose(target, photo_type, photo_url, width = nil, height = nil, position = nil)
    changed = false
    photo = Photo.where(source_url: photo_url, target: target).first_or_initialize
    if photo.new_record?
      photo.photo_type = photo_type
      photo.remote_file_url = photo_url if photo_url
      photo.source_url = photo_url
      photo.width = width
      photo.height = height
      photo.position = position
      changed = true if photo.changed?
      photo.save
      changed
    end
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
