require File.expand_path('../../helper', File.dirname(__FILE__))

class ReservedInstancesOfferingsTest < Test::Unit::TestCase
  context "ReservedInstancesOfferingParser:" do
    context "Parsing the result of a call to DescribeReservedInstancesOfferings" do
      setup {
        ec2 = Awsum::Ec2.new('abc', 'xyz')
        xml = load_fixture('ec2/reserved_instances_offerings')
        parser = Awsum::Ec2::ReservedInstancesOfferingParser.new(ec2)
        @result = parser.parse(xml)
      }

      should "return an array of reserved instance offerings" do
        assert @result.is_a?(Array)
        assert_equal Awsum::Ec2::ReservedInstancesOffering, @result[0].class
      end

      context ", the first offering" do
        setup {
          @offering = @result[0]
        }

        should "have the correct id" do
          assert_equal "e5a2ff3b-f6eb-4b4e-83f8-b879d7060257", @offering.id
        end

        should "have the correct instance type" do
          assert_equal "c1.medium", @offering.instance_type
        end

        should "have the correct availability zone" do
          assert_equal "us-east-1b", @offering.availability_zone
        end

        should "have the correct duration" do
          assert_equal 94608000, @offering.duration
        end

        should "have the correct fixed price" do
          assert_equal 1000.0, @offering.fixed_price
        end

        should "have the correct usage price" do
          assert_equal 0.06, @offering.usage_price
        end

        should "have the correct product description" do
          assert_equal 'Linux/UNIX', @offering.product_description
        end
      end
    end
  end
end
