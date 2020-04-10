class Photo < ApplicationRecord
  mount_uploader :file, PhotoUploader

  scope :logo, -> { where(photo_type: 'logo') }

  belongs_to :target, polymorphic: true
  before_create :set_filename

  audited

  def self.compose(target, photo_type, photo_url, width = nil, height = nil, position = nil, id = nil, is_cover = 0)
    changed = false
    photo = Photo.where(source_url: photo_url, target: target).first_or_initialize
    if photo.new_record?
      photo.photo_type = photo_type
      photo.remote_file_url = photo_url if photo_url
      photo.source_url = photo_url
      photo.width = width
      photo.height = height
      photo.position = position
      photo.image_id = id
      photo.is_cover = is_cover
      changed = true if photo.changed?
      photo.save
      changed
    end
  end

  def set_filename
    self.name = file.filename
  end

  def url
    source_url
  end

  def thumb_url
    source_url
  end
end
