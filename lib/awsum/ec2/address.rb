require 'awsum/ec2/parsers/address_parser'

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

      # Will associate this address with an instance (even if it is already associated with another instance)
      def associate!(instance_id)
        @ec2.associate_address instance_id, @public_ip
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
  end
end
