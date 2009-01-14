require File.expand_path('../../helper', File.dirname(__FILE__))

class VolumesTest < Test::Unit::TestCase
  context "VolumeParser:" do
    context "Parsing the result of a call to DescribeVolumes" do
      setup {
        ec2 = Awsum::Ec2.new('abc', 'xyz')
        xml = load_fixture('ec2/volumes')
        parser = Awsum::Ec2::VolumeParser.new(ec2)
        @result = parser.parse(xml)
      }

      should "return an array of volumes" do
        assert @result.is_a?(Array)
        assert @result[0].is_a?(Awsum::Ec2::Volume)
      end

      context ", the first volume" do
        setup {
          @volume = @result[0]
        }

        should "have the correct id" do
          assert_equal "vol-44d6322d", @volume.id
        end

        should "have the correct size" do
          assert_equal 10, @volume.size
        end

        should "have the correct snapshot id" do
          assert_nil @volume.snapshot_id
        end

        should "have the correct availability zone" do
          assert_equal "us-east-1b", @volume.availability_zone
        end

        should "have the correct status" do
          assert_equal "available", @volume.status
        end

        should "have the correct create time" do
          assert_equal '2009-01-14T03:57:08.000Z', @volume.create_time.strftime('%Y-%m-%dT%H:%M:%S.000Z')
        end

#TODO: Test attachment sets
      end
    end
  end
end
