require File.expand_path('../../helper', File.dirname(__FILE__))

class BucketsTest < Test::Unit::TestCase
  context "BucketParser:" do
    context "Parsing the result of GET" do
      setup {
        s3 = Awsum::S3.new('abc', 'xyz')
        xml = load_fixture('s3/buckets')
        parser = Awsum::S3::BucketParser.new(s3)
        @result = parser.parse(xml)
      }

      should "return an array of buckets" do
        assert @result.is_a?(Array)
        assert @result[0].is_a?(Awsum::S3::Bucket)
      end

      context ", the first bucket" do
        setup {
          @bucket = @result[0]
        }

        should "have the correct name" do
          assert_equal "test-bucket", @bucket.name
        end

        should "have the correct creation date" do
          assert_equal Time.parse("2008-12-04T16:08:03.000Z"), @bucket.creation_date
        end
      end

      context ", the second bucket" do
        setup {
          @bucket = @result[1]
        }

        should "have the correct name" do
          assert_equal "another-test-bucket", @bucket.name
        end

        should "have the correct creation date" do
          assert_equal Time.parse("2009-01-02T08:25:27.000Z"), @bucket.creation_date
        end
      end
    end
  end

  context "Bucket: " do
    setup {
      @s3 = Awsum::S3.new('abc', 'xyz')
    }

    should "be able to create a bucket without calling the S3 API" do
      bucket = @s3.bucket('test-bucket')
      assert_equal 'test-bucket', bucket.name
    end
  end
end
