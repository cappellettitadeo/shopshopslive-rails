class StoreSerializer
  include FastJsonapi::ObjectSerializer

  attributes :name, :description, :ctr_store_id, :website, :source_url, :street, :unit_no, :city,
             :state, :country, :zipcode, :phone, :currency, :latitude, :logitude, :source_url,
             :source_id
end
