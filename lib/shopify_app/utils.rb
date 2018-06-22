module ShopifyApp
  class Utils
    class << self
      def valid_hmac?(hmac, request)
        h = request.params.reject{|k,_| k == 'hmac' || k == 'signature'}
        query = URI.escape(h.sort.collect{|k,v| "#{k}=#{v}"}.join('&'))
        digest = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), API_SECRET, query)

        hmac == digest
      end
    end
  end
end
