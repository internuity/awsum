require 'time'

module Awsum
  class Ec2
    class PurchaseReservedInstancesOfferingParser < Awsum::Parser #:nodoc:
      def initialize(ec2)
        @ec2 = ec2
        @ids = []
        @text = nil
        @stack = []
      end

      def tag_start(tag, attributes)
        @text = ''
      end

      def text(text)
        @text << text unless @text.nil?
      end

      def tag_end(tag)
        case tag
          when 'reservedInstancesId'
            text = @text.strip
            @ids << (text == '' ? nil : text)
        end
      end

      def result
        @ids
      end
    end
  end
end
