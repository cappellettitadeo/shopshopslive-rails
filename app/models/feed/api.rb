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
        products = Product.where(query_string).order("created_at DESC").page(params[:page]).limit(params[:limit])
      end
      products
		end

    def self.build_query(params)
      query_array = []
      if params[:title]
        query_array << "(name = '#{params[:title]}')"
      end
      if params[:vendor]
        vendor_id = Vendor.find_by_name(params[:vendor]).id rescue 0
        query_array << "(vendor_id = #{vendor_id})"
      end
      if params[:category]
        category = Category.find_by_name(params[:category])
        ids = category.products.pluck(:id) rescue []
        ids = 0 if ids.empty?
        query_array << "(id IN (#{ids}))"
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
