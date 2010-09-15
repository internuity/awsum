module Awsum
  class Ec2
    class AvailabilityZone
      attr_reader :name, :state, :availability_zone_name

      def initialize(ec2, name, state, availability_zone_name) #:nodoc:
        @ec2 = ec2
        @name = name
        @state = state
        @availability_zone_name = availability_zone_name
      end
    end

    class AvailabilityZoneParser < Awsum::Parser #:nodoc:
      def initialize(ec2)
        @ec2 = ec2
        @availability_zones = []
        @text = nil
        @stack = []
      end

      def tag_start(tag, attributes)
        case tag
          when 'availabilityZoneInfo'
            @stack << 'availabilityZoneInfo'
          when 'item'
            case @stack[-1]
              when 'availabilityZoneInfo'
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
          when 'DescribeAvailabilityZonesResponse', 'requestId'
            #no-op
          when 'availabilityZoneInfo'
            @stack.pop
          when 'item'
            case @stack[-1]
              when 'availabilityZoneInfo'
                @availability_zones << AvailabilityZone.new(
                                @ec2,
                                @current['zoneName'], 
                                @current['zoneState'],
                                @current['regionName']
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
        @availability_zones
      end
    end
  end
end
