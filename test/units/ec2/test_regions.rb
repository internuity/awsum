require File.expand_path('../../helper', File.dirname(__FILE__))

class RegionsTest < Test::Unit::TestCase
  context "RegionParser:" do
    context "Parsing the result of a call to DescribeRegions" do
      setup {
        ec2 = Awsum::Ec2.new('abc', 'xyz')
        xml = load_fixture('ec2/regions')
        parser = Awsum::Ec2::RegionParser.new(ec2)
        @result = parser.parse(xml)
      }

      should "return an array of regions" do
        assert @result.is_a?(Array)
        assert @result[0].is_a?(Awsum::Ec2::Region)
      end

      context ", the first region" do
        setup {
          @region = @result[0]
        }

        should "have the correct name" do
          assert_equal "eu-west-1", @region.name
        end

        should "have the correct end point" do
          assert_equal 'eu-west-1.ec2.amazonaws.com', @region.end_point
        end
      end
    end
  end
end
