module Awsum
  class Ec2
    class ReservedInstanceParser < Awsum::Parser #:nodoc:
      def initialize(ec2)
        @ec2 = ec2
        @reserved_instances = []
        @text = nil
        @stack = []
      end

      def tag_start(tag, attributes)
        case tag
          when 'reservedInstancesSet'
            @stack << 'reservedInstancesSet'
          when 'item'
            case @stack[-1]
              when 'reservedInstancesSet'
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
          when 'requestId'
            #no-op
          when 'reservedInstancesSet'
            @stack.pop
          when 'item'
            case @stack[-1]
              when 'reservedInstancesSet'
                @reserved_instances << ReservedInstance.new(
                                         @ec2,
                                         @current['reservedInstancesId'],
                                         @current['instanceType'],
                                         @current['availabilityZone'],
                                         Time.parse(@current['start']),
                                         @current['duration'].to_i,
                                         @current['fixedPrice'].to_f,
                                         @current['usagePrice'].to_f,
                                         @current['instanceCount'].to_i,
                                         @current['productDescription'],
                                         @current['state']
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
        @reserved_instances
      end
    end
  end
end
