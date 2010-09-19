require 'awsum/ec2/parsers/region_parser'

module Awsum
  class Ec2
    class Region
      attr_reader :name, :end_point

      def initialize(ec2, name, end_point) #:nodoc:
        @ec2 = ec2
        @name = name
        @end_point = end_point
      end

      # List the AvailabilityZone(s) of this Region
      def availability_zones
        use do
          @ec2.availability_zones
        end
      end

      # Operate all Awsum::Ec2 methods against this Region
      #
      # ====Example
      #
      #   ec2.region('eu-west-1').use
      #   ec2.availability_zones #Will give you all the availability zones in the eu-west-1 region
      #
      #   Alternative:
      #   ec2.region('eu-west-1') do |region|
      #     region.availability_zones
      #   end
      def use(&block)
        old_host = @ec2.host
        @ec2.host = end_point
        if block_given?
          block.arity < 1 ? instance_eval(&block) : block[self]
        else
          self
        end
      ensure
        @ec2.host = old_host
      end

    private
      #--
      # Will pass all missing methods onto the ec2 object
      def method_missing(method_name, *args, &block)
        use do
          @ec2.send(method_name, *args, &block)
        end
      end
    end
  end
end
