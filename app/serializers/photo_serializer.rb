class PhotoSerializer
  include FastJsonapi::ObjectSerializer

  attributes :width, :height, :url, :thumb_url
end
