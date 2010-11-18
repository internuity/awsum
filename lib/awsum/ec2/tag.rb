require 'awsum/ec2/parsers/tag_parser'

module Awsum
  class Ec2
    class Tag
      attr_reader :resource_id, :resource_type, :key, :value

      def initialize(ec2, resource_id, resource_type, key, value) #:nodoc:
        @ec2 = ec2
        @resource_id = resource_id
        @resource_type = resource_type
        @key = key
        @value = value
      end
    end
  end
end
