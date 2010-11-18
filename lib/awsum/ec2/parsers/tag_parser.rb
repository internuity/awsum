module Awsum
  class Ec2
    class TagParser < Awsum::Parser #:nodoc:
      def initialize(ec2)
        @ec2 = ec2
        @tags = []
        @text = nil
        @stack = []
      end

      def tag_start(tag, attributes)
        case tag
          when 'tagSet'
            @stack << tag
          when 'item'
            case @stack[-1]
              when 'tagSet'
                @current = {}
            end
        end
        @text = ''
      end

      def text(text)
        @text << text unless @text.nil?
      end

      def tag_end(tag)
        case tag
          when 'tagSet'
            @stack.pop
          when 'item'
            case @stack[-1]
              when 'tagSet'
                @tags << Tag.new(
                           @ec2,
                           @current['resourceId'],
                           @current['resourceType'],
                           @current['key'],
                           @current['value']
                         )
            end
          else
            unless @text.nil? || @current.nil?
              text = @text.strip
              @current[tag] = (text == '' ? nil : text)
            end
        end
      end

      def result
        @tags
      end
    end
  end
end
