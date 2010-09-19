require 'awsum/ec2/parsers/purchase_reserved_instances_offering_parser'
require 'awsum/ec2/parsers/reserved_instance_parser'

module Awsum
  class Ec2
    class ReservedInstance
      attr_reader :id, :instance_type, :availability_zone, :start, :duration, :fixed_price, :usage_price, :instance_count, :product_description, :state

      def initialize(ec2, id, instance_type, availability_zone, start, duration, fixed_price, usage_price, instance_count, product_description, state)
        @ec2 = ec2
        @id = id
        @instance_type = instance_type
        @availability_zone = availability_zone
        @start = start
        @duration = duration
        @fixed_price = fixed_price
        @usage_price = usage_price
        @instance_count = instance_count
        @product_description = product_description
        @state = state
      end
    end
  end
end
