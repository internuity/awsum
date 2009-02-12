require File.expand_path('../../helper', File.dirname(__FILE__))

class KeysTest < Test::Unit::TestCase
  context "KeyParser:" do
    context "Parsing the result of GET" do
      setup {
        s3 = Awsum::S3.new('abc', 'xyz')
        xml = load_fixture('s3/keys')
        parser = Awsum::S3::KeyParser.new(s3)
        @result = parser.parse(xml)
      }

      should "return an array of keys" do
        assert @result.is_a?(Array)
        assert @result[0].is_a?(Awsum::S3::Key)
      end

      context ", the first key" do
        setup {
          @key = @result[0]
        }

        should "have the correct name" do
          assert_equal "test/photo1.jpg", @key.name
        end

        should "have the correct last modification date" do
          assert_equal Time.parse("2008-12-07T13:47:59.000Z"), @key.last_modified
        end

        should "have the correct etag" do
          assert_equal "\"03bde534951a1c099724f569a53acb1e\"", @key.etag
        end

        should "have the correct size" do
          assert_equal 203841, @key.size
        end

        should "have the correct owner id" do
          assert_equal '1111111111111111111111111111111111111111111111111111111111111111', @key.owner['id']
        end

        should "have the correct owner name" do
          assert_equal 'AAAAAA', @key.owner['name']
        end

        should "have the correct storage class" do
          assert_equal 'STANDARD', @key.storage_class
        end
      end

      context ", the second key" do
        setup {
          @key = @result[1]
        }

        should "have the correct name" do
          assert_equal "test/photo2.jpg", @key.name
        end

        should "have the correct last modification date" do
          assert_equal Time.parse("2008-12-07T13:48:13.000Z"), @key.last_modified
        end
      end
    end
  end
end