module Awsum
  class Ec2
    class RegionParser < Awsum::Parser #:nodoc:
      def initialize(ec2)
        @ec2 = ec2
        @regions = []
        @text = nil
        @stack = []
      end

      def tag_start(tag, attributes)
        case tag
          when 'regionInfo'
            @stack << 'regionInfo'
          when 'item'
            case @stack[-1]
              when 'regionInfo'
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
          when 'DescribeRegionsResponse', 'requestId'
            #no-op
          when 'regionInfo'
            @stack.pop
          when 'item'
            case @stack[-1]
              when 'regionInfo'
                @regions << Region.new(
                                @ec2,
                                @current['regionName'],
                                @current['regionEndpoint']
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
        @regions
      end
    end
  end
end
