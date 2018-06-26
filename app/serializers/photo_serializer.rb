class PhotoSerializer
  include FastJsonapi::ObjectSerializer

  attributes :width, :height

  attribute :sourceUrl do |photo|
    photo.url
  end
end
