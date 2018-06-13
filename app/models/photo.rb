class Photo < ApplicationRecord
  mount_uploader :file, PhotoUploader

  belongs_to :target, polymorphic: true
  before_create :set_filename

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
