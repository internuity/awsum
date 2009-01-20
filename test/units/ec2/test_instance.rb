require File.expand_path('../../helper', File.dirname(__FILE__))

class InstancesTest < Test::Unit::TestCase
  context "InstanceParser:" do
    context "Parsing the result of a call to DescribeInstances" do
      setup {
        ec2 = Awsum::Ec2.new('abc', 'xyz')
        xml = load_fixture('ec2/instances')
        parser = Awsum::Ec2::InstanceParser.new(ec2)
        @result = parser.parse(xml)
      }

      should "return an array of instances" do
        assert @result.is_a?(Array)
        assert_equal Awsum::Ec2::Instance, @result[0].class
      end

      context ", the first instance" do
        setup {
          @instance = @result[0]
        }

        should "have the correct id" do
          assert_equal "i-3f1cc856", @instance.id
        end

        should "have the correct private DNS name" do
          assert_equal "ip-10-255-255-255.ec2.internal", @instance.private_dns_name
        end

        should "have the correct public DNS name" do
          assert_equal "ec2-75-255-255-255.compute-1.amazonaws.com", @instance.dns_name
        end

        should "have the correct key name" do
          assert_equal "gsg-keypair", @instance.key_name
        end

        should "have the correct launch index" do
          assert_equal 0, @instance.launch_index
        end

        should "have the correct type" do
          assert_equal 'm1.small', @instance.type
        end

        should "have the correct availability zone" do
          assert_equal 'us-east-1b', @instance.availability_zone
        end

        should "have the correct launch time" do
          assert_equal '2008-06-18T12:51:52.000Z', @instance.launch_time.strftime('%Y-%m-%dT%H:%M:%S.000Z')
        end

        should "have the correct state" do
          assert_equal({:code => 0, :name => 'pending'}, @instance.state)
        end
      end

      context ", the second instance" do
        setup {
          @instance = @result[1]
        }

        should "have the correct state" do
          assert_equal({:code => 16, :name => 'running'}, @instance.state)
        end
      end
    end

    context "Parsing the result of a call to RunInstances" do
      setup {
        ec2 = Awsum::Ec2.new('abc', 'xyz')
        xml = load_fixture('ec2/run_instances')
        parser = Awsum::Ec2::InstanceParser.new(ec2)
        @result = parser.parse(xml)
      }

      should "return an array of instances" do
        assert @result.is_a?(Array)
        assert_equal Awsum::Ec2::Instance, @result[0].class
      end

      context ", the first instance" do
        setup {
          @instance = @result[0]
        }

        should "have the correct id" do
          assert_equal "i-f92fa890", @instance.id
        end

        should "have the correct private DNS name" do
          assert_equal nil, @instance.private_dns_name
        end

        should "have the correct public DNS name" do
          assert_equal nil, @instance.dns_name
        end

        should "have the correct key name" do
          assert_equal nil, @instance.key_name
        end

        should "have the correct launch index" do
          assert_equal 0, @instance.launch_index
        end

        should "have the correct type" do
          assert_equal 'm1.small', @instance.type
        end

        should "have the correct availability zone" do
          assert_equal 'us-east-1b', @instance.availability_zone
        end

        should "have the correct launch time" do
          assert_equal '2009-01-11T13:09:01.000Z', @instance.launch_time.strftime('%Y-%m-%dT%H:%M:%S.000Z')
        end

        should "have the correct state" do
          assert_equal({:code => 0, :name => 'pending'}, @instance.state)
        end
      end
    end
  end
end
