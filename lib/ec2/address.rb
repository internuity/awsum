module Awsum
  class Ec2
    class Address
      attr_reader :public_ip, :instance_id

      def initialize(ec2, public_ip, instance_id) #:nodoc:
        @ec2 = ec2
        @public_ip = public_ip
        @instance_id = instance_id
      end

      # Get the Instance associated with this address.
      #
      # Returns nil if no instance is associated.
      def instance
        @ec2.instance(@instance_id) if @instance_id
      end

      # Will associate this address with an instance
      #
      # Raises an error if the address is already associated with an instance
      def associate(instance_id)
        if @instance_id.nil?
          @ec2.associate_address instance_id, @public_ip
        else
          raise 'Cannot associate with an already associated instance' #FIXME: Write a better Awsum error here'
        end
      end

      # Will disassociate this address from it's instance
      #
      # Raises an error if the address is not associated with an instance
      def disassociate
        if @instance_id.nil?
          raise 'Not associated' #FIXME: Write a better Awsum error here'
        else
          result = @ec2.disassociate_address @public_ip
          @instance_id = nil
          result
        end
      end

      # Will release this address
      #
      # Raises an error if the address is associated with an instance
      def release
        if @instance_id.nil?
          @ec2.release_address @public_ip
        else
          raise 'Associated with an instance' #FIXME: Write a better Awsum error here'
        end
      end

      # Will release this address regardless of whether it is associated with an instance or not.
      def release!
        @ec2.release_address! @public_ip
      end
    end

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
          when 'DescribeAddressesResponse', 'requestId'
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
