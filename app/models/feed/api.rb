module Feed
  class Api
    def self.search(params)
      ids = params[:ids] ? params[:ids].split(',').map(&:strip) : []
      if ids.present?
        products = Product.where(ctr_product_id: ids)
      else
        params[:limit] = (params[:limit] || 50).to_i
        params[:page] = (params[:page] || 1).to_i
        query_string = build_query(params)
        products = Product.where(query_string)
      end
      products
		end

    def self.build_query(params)
      query_array = []
      if params[:title]
        query_array << "(title = #{params[:title]})"
      end
      if params[:vendor]
        vendor = Vendor.find_by_name(params[:vendor])
        query_array << "(vendor_id = #{vendor.id})" if vendor
      end
      if params[:category]
        category = Category.find_by_name(params[:category])
        if category
          ids = category.products.pluck(:id)
          query_array << "(id IN (#{ids}))"
        end
      end
      if params[:created_at_min]
        query_array << "(created_at >= #{params[:created_at_min]})"
      end
      if params[:created_at_max]
        query_array << "(created_at <= #{params[:created_at_max]})"
      end
      if params[:updated_at_min]
        query_array << "(updated_at >= #{params[:updated_at_min]})"
      end
      if params[:updated_at_max]
        query_array << "(updated_at <= #{params[:updated_at_max]})"
      end
      query_array.join(' AND ')
    end
	end
end
