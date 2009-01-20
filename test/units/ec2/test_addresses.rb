require File.expand_path('../../helper', File.dirname(__FILE__))

class AddressesTest < Test::Unit::TestCase
  context "AddressParser:" do
    context "Parsing the result of a call to DescribeAddresses" do
      setup {
        ec2 = Awsum::Ec2.new('abc', 'xyz')
        xml = load_fixture('ec2/addresses')
        parser = Awsum::Ec2::AddressParser.new(ec2)
        @result = parser.parse(xml)
      }

      should "return an array of addresses" do
        assert @result.is_a?(Array)
        assert @result[0].is_a?(Awsum::Ec2::Address)
      end

      context ", the first address" do
        setup {
          @address = @result[0]
        }

        should "have the correct ip address" do
          assert_equal "127.0.0.1", @address.public_ip
        end

        should "have the correct instance id" do
          assert_equal 'i-3f1cc856', @address.instance_id
        end
      end
    end
    
    context "Parsing the result of a call to AllocateAddress" do
      setup {
        ec2 = Awsum::Ec2.new('abc', 'xyz')
        xml = load_fixture('ec2/allocate_address')
        parser = Awsum::Ec2::AddressParser.new(ec2)
        @result = parser.parse(xml)
      }

      should "return an address" do
        assert Awsum::Ec2::Address, @result.class
      end

      context ", the address" do
        setup {
          @address = @result[0]
        }

        should "have the correct ip address" do
          assert_equal "127.0.0.1", @address.public_ip
        end

        should "have a nil instance id" do
          assert_nil @address.instance_id
        end
      end
    end
  end
end
