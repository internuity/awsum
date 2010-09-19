module Awsum
  class Ec2
    class RegisterImageParser < Awsum::Parser #:nodoc:
      def initialize(ec2)
        @ec2 = ec2
        @image = nil
        @text = nil
      end

      def tag_start(tag, attributes)
        case tag
          when 'imageId'
            @text = ''
        end
      end

      def text(text)
        @text << text unless @text.nil?
      end

      def tag_end(tag)
        case tag
          when 'imageId'
            @image = @text
            @text = nil
        end
      end

      def result
        @image
      end
    end
  end
end
