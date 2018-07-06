class StoreSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :ctr_store_id, :name, :description, :ctr_store_id, :website, :street, :unit_no, :city,
             :state, :country, :zipcode, :phone, :currency, :lat, :lng

  attribute :photos do |store|
    photos = store.photos
    PhotoSerializer.new(photos).serializable_hash
  end
end
