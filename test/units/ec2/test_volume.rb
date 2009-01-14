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
          assert_equal "in-use", @volume.status
        end

        should "have the correct create time" do
          assert_equal '2009-01-14T03:57:08.000Z', @volume.create_time.strftime('%Y-%m-%dT%H:%M:%S.000Z')
        end

        should "have the correct instance id" do
          assert_equal 'i-3f1cc856', @volume.instance_id
        end

        should "have the correct device" do
          assert_equal '/dev/sdb', @volume.device
        end

        should "have the correct attachment_status" do
          assert_equal 'attached', @volume.attachment_status
        end

        should "have the correct attach time" do
          assert_equal '2009-01-14T04:34:35.000Z', @volume.attach_time.strftime('%Y-%m-%dT%H:%M:%S.000Z')
        end
      end
    end
  end
end
