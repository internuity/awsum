require 'awsum/ec2/parsers/reserved_instances_offering_parser'

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
  end
end
