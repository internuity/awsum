module Awsum
  class Ec2
    class AddressParser < Awsum::Parser #:nodoc:
      def initialize(ec2)
        @ec2 = ec2
        @addresses = []
        @text = nil
        @stack = []
      end

      def tag_start(tag, attributes)
        #Quick hack so we can use the same parser for AllocateAddress which doesn't use the item tag to wrap the address information
        if tag == 'AllocateAddressResponse'
          @stack << 'addressesSet'
        end

        case tag
          when 'addressesSet'
            @stack << 'addressesSet'
          when 'item', 'AllocateAddressResponse'
            case @stack[-1]
              when 'addressesSet'
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
          when 'DescribeAddressesResponse'
            #no-op
          when 'addressesSet'
            @stack.pop
          when 'item', 'AllocateAddressResponse'
            case @stack[-1]
              when 'addressesSet'
                @addresses << Address.new(
                                @ec2,
                                @current['publicIp'],
                                @current['instanceId']
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
        @addresses
      end
    end
  end
end
