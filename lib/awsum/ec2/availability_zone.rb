require 'awsum/ec2/parsers/availability_zone_parser'

module Awsum
  class Ec2
    class AvailabilityZone
      attr_reader :name, :state, :region_name

      def initialize(ec2, name, state, region_name) #:nodoc:
        @ec2 = ec2
        @name = name
        @state = state
        @region_name = region_name
      end
    end
  end
end
