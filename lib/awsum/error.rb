module Awsum
  class Error < StandardError
    attr_reader :response_code, :code, :message, :request_id, :additional

    def initialize(response)
      @response_code = response.code
      parser = ErrorParser.new
      parser.parse(response.body)
      @code = parser.code
      @message = parser.message
      @request_id = parser.request_id
      @additional = parser.additional
    end

    def inspect
      "#<Awsum::Error response_code=#{@response_code} code=#{@code} request_id=#{@request_id} message=#{@message}>"
    end

  private
    class ErrorParser < Awsum::Parser #:nodoc:
      attr_reader :code, :message, :request_id, :additional

      def initialize
        @additional = {}
        @text = ""
      end

      def tag_start(tag, attributes)
      end

      def text(text)
        @text << text unless @text.nil?
      end

      def tag_end(tag)
        text = @text.strip
        return if text.blank?

        case tag
          when 'Code'
            @code = text
          when 'Message'
            @message = text
          when 'RequestID', 'RequestId'
            @request_id = text
          else
            @additional[tag] = text
        end
        @text = ''
      end
    end
  end
end
