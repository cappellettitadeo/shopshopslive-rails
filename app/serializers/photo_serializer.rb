class PhotoSerializer
  include FastJsonapi::ObjectSerializer
  attributes :width, :height, :url, :thumb_url, :image_id, :is_cover
end
