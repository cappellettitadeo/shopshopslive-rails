class Photo < ApplicationRecord
  mount_uploader :file, PhotoUploader

  belongs_to :target, polymorphic: true
  before_create :set_filename

  def self.compose(target, photo_type, photo_url, width, height, position)
    if Photo.find_by(source_url: photo_url, target_id: target.id).nil?
      photo = new(target: target)
      photo.photo_type = photo_type
      photo.remote_file_url = photo_url if photo_url
      photo.source_url = photo_url
      photo.width = width
      photo.height = height
      photo.position = position
      photo.save
      photo
    else
      update(target, photo_type, photo_url, width, height, position)
    end

  end

  def self.update(target, photo_type, photo_url, width, height, position)
    photo = Photo.find_by(source_url: photo_url, target_id: target.id)
    if photo
      photo.width = width
      photo.height = height
      photo.position = position
      photo.save
      photo
    else
      Photo.compose(target, photo_type, photo_url, width, height, position)
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
