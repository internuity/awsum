module Awsum
  class S3
    class Headers #:nodoc:
      def initialize(response)
        @response = response
      end

      # Locking down to HTTPHeader methods only
      def method_missing(method, *args, &block)
        if !%w(body body_permitted? entity inspect read_body to_ary value).include?(method.to_s) && @response.respond_to?(method)
          @response.send(method, *args, &block)
        else
          raise NoMethodError.new("undefined method `#{method}' for #{inspect}")
        end
      end

      def inspect
        headers = []
        @response.canonical_each do |h,v| headers << h end
        "#<Awsum::S3::Headers \"#{headers.join('", "')}\">"
      end
    end
  end
end
