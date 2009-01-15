require File.expand_path('../../helper', File.dirname(__FILE__))

class SnapshotsTest < Test::Unit::TestCase
  context "SnapshotParser:" do
    context "Parsing the result of a call to DescribeSnapshots" do
      setup {
        ec2 = Awsum::Ec2.new('abc', 'xyz')
        xml = load_fixture('ec2/snapshots')
        parser = Awsum::Ec2::SnapshotParser.new(ec2)
        @result = parser.parse(xml)
      }

      should "return an array of snapshots" do
        assert @result.is_a?(Array)
        assert @result[0].is_a?(Awsum::Ec2::Snapshot)
      end

      context ", the first snapshot" do
        setup {
          @snapshot = @result[0]
        }

        should "have the correct id" do
          assert_equal "snap-747c911d", @snapshot.id
        end

        should "have the correct volume id" do
          assert "vol-79d13510", @snapshot.volume_id
        end

        should "have the correct status" do
          assert_equal "completed", @snapshot.status
        end

        should "have the correct start time" do
          assert_equal '2009-01-15T03:59:26.000Z', @snapshot.start_time.strftime('%Y-%m-%dT%H:%M:%S.000Z')
        end

        should "have the correct progress" do
          assert_equal '100%', @snapshot.progress
        end
      end
    end
  end
end
