require 'parser'

module Awsum
  class Error < StandardError
    attr_reader :response_code, :code, :message, :request_id

    def initialize(response)
      @response_code = response.code
      parser = ErrorParser.new
      parser.parse(response.body)
      @code = parser.code
      @message = parser.message
      @request_id = parser.request_id
    end

  private
    class ErrorParser < Awsum::Parser #:nodoc:
      attr_reader :code, :message, :request_id

      def tag_start(tag, attributes)
        case tag
          when 'Code', 'Message', 'RequestID'
            @text = ""
        end
      end

      def text(text)
        @text << text unless @text.nil?
      end

      def tag_end(tag)
        case tag
          when 'Code'
            @code = @text
          when 'Message'
            @message = @text
          when 'RequestID'
            @request_id = @text
        end
        @text = nil
      end
    end
  end
end
