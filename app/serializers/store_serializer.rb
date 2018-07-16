class StoreSerializer
  include FastJsonapi::ObjectSerializer

  attributes :id, :ctr_store_id, :name, :description, :website, :street, :unit_no, :city,
             :state, :country, :zipcode, :phone, :currency, :lat, :lng, :status

  attribute :photos do |store|
    photos = store.photos
    PhotoSerializer.new(photos).serializable_hash[:data]
  end
end
