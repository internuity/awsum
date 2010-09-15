require 'time'

module Awsum
  class Ec2
    class ReservedInstancesOffering
      attr_reader :id, :instance_type, :availability_zone, :duration, :fixed_price, :usage_price, :product_description

      def initialize(ec2, id, instance_type, availability_zone, duration, fixed_price, usage_price, product_description)
        @ec2 = ec2
        @id = id
        @instance_type = instance_type
        @availability_zone = availability_zone
        @duration = duration
        @fixed_price = fixed_price
        @usage_price = usage_price
        @product_description = product_description
      end
    end

    class ReservedInstancesOfferingParser < Awsum::Parser #:nodoc:
      def initialize(ec2)
        @ec2 = ec2
        @offerings = []
        @text = nil
        @stack = []
      end

      def tag_start(tag, attributes)
        case tag
          when 'reservedInstancesOfferingsSet'
            @stack << 'reservedInstancesOfferingsSet'
          when 'item'
            case @stack[-1]
              when 'reservedInstancesOfferingsSet'
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
          when 'reservedInstancesOfferingsSet'
            @stack.pop
          when 'item'
            case @stack[-1]
              when 'reservedInstancesOfferingsSet'
                @offerings << ReservedInstancesOffering.new(
                                @ec2,
                                @current['reservedInstancesOfferingId'], 
                                @current['instanceType'], 
                                @current['availabilityZone'], 
                                @current['duration'].to_i, 
                                @current['fixedPrice'].to_f,
                                @current['usagePrice'].to_f,
                                @current['productDescription']
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
        @offerings
      end
    end
  end
end
