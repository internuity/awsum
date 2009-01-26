require File.expand_path('../../helper', File.dirname(__FILE__))

class S3Test < Test::Unit::TestCase
  def setup
    @s3 = Awsum::S3.new('abc', 'xyz')
  end

  context "Buckets: " do
    context "naming a bucket" do
      should "not have an ip address style name" do
        assert_raise ArgumentError do
          @s3.create_bucket('192.168.2.1')
        end
      end

      should "not start with punctuation" do
        assert_raise ArgumentError do
          @s3.create_bucket('-name')
          @s3.create_bucket('.name')
          @s3.create_bucket('_name')
        end
      end

      should "not end with a dash" do
        assert_raise ArgumentError do
          @s3.create_bucket('name-')
        end
      end

      should "not have a dash to the left of a period" do
        assert_raise ArgumentError do
          @s3.create_bucket('name-.test')
        end
      end

      should "not have a dash to the right of a period" do
        assert_raise ArgumentError do
          @s3.create_bucket('name.-test')
        end
      end

      should "be able to start with a number" do
        @s3.expects(:send_s3_request)

        assert_nothing_raised do
          @s3.create_bucket('2name')
        end
      end

      should "not be shorter than 3 characters" do
        assert_raise ArgumentError do
          @s3.create_bucket('ab')
        end
      end

      should "not be longer than 63 characters" do
        assert_raise ArgumentError do
          @s3.create_bucket((0..63).collect{'a'}.join)
        end
      end

      should "succeed" do
        response = stub('Http Response', :is_a? => true)
        @s3.expects(:send_s3_request).returns(response)

        assert @s3.create_bucket('test')
      end
    end

    context "retrieving a list of buckets" do
      setup {
        xml = load_fixture('s3/buckets')
        response = stub('Http Response', :body => xml)
        @s3.expects(:send_s3_request).returns(response)

        @result = @s3.buckets
      }

      should "return an array of buckets" do
        assert @result.is_a?(Array)
        assert_equal Awsum::S3::Bucket, @result[0].class
      end
    end

    context "deleting a bucket" do
      setup {
        response = stub('Http Response', :is_a? => true)
        @s3.expects(:send_s3_request).returns(response)
      }

      should "succeed" do
        assert @s3.delete_bucket('test')
      end
    end
  end
end
