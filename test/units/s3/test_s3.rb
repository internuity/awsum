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

    context "a bucket" do
      setup {
        @bucket = Awsum::S3::Bucket.new(@s3, 'test', Time.now)
      }

      should "be able to delete itself" do
        response = stub('Http Response', :is_a? => true)
        @s3.expects(:send_s3_request).returns(response)

        assert @bucket.delete
      end

      should "be able to delete itself with keys" do
        xml = load_fixture('s3/keys')
        response = stub('Http Response', :is_a? => true, :body => xml)
        requests = sequence('requests')
        ['get keys', 'delete first key', 'delete second key', 'delete bucket'].each do |process_request|
          @s3.expects(:send_s3_request).returns(response).in_sequence(requests)
        end

        assert @bucket.delete!
      end
    end
  end

  context "Keys: " do
    context "creating a key" do
      context "with a string" do
        setup {
          response = stub('Http Response', :is_a? => true)
          @s3.expects(:send_s3_request).returns(response)
        }

        should "send data" do
          assert @s3.create_key('test', 'test.txt', 'Some text')
        end
      end

      context "with an IO object" do
        setup {
          response = stub('Http Response', :is_a? => true)
          @s3.expects(:process_request).returns(response)

          lstat = stub('lstat', :size => 100)
          @data = stub('IO', :nil? => false)
          @data.expects(:respond_to?).at_least_once.returns(true)
          @data.expects(:lstat).returns(lstat)
          read_sequence = sequence('read_sequence')
          @data.expects(:read).returns((1..100).collect{|i| 'x'}.join('')).in_sequence(read_sequence)
          @data.expects(:read).returns(nil).in_sequence(read_sequence)
          @data.expects(:rewind).returns(0)
        }

        should "send data" do
          assert @s3.create_key('test', 'test.txt', @data)
        end
      end
    end

    context "deleting a key" do
      setup {
        response = stub('Http Response', :is_a? => true)
        @s3.expects(:send_s3_request).returns(response)
      }

      should "succeed" do
        @s3.delete_key('test', 'test.txt')
      end
    end

    context "copying a key" do
      context "to a different bucket with same name" do
        setup {
          response = stub('Http Response', :is_a? => true, :body => '')
          @s3.expects(:send_s3_request).returns(response)
        }

        should "succeed" do
          assert @s3.copy_key('test', 'test.txt', 'test2')
        end
      end

      context "within the same bucket with a different name" do
        setup {
          response = stub('Http Response', :is_a? => true, :body => '')
          @s3.expects(:send_s3_request).returns(response)
        }

        should "succeed" do
          assert @s3.copy_key('test', 'test.txt', nil, 'test2.txt')
        end
      end

      context "replacing headers and meta-data" do
        setup {
          response = stub('Http Response', :is_a? => true, :body => '')
          @s3.expects(:send_s3_request).returns(response)
        }

        should "succeed" do
          assert @s3.copy_key('test', 'test.txt', nil, nil, {'New-Header' => 'two'})
        end
      end

      context "within the same bucket, with the same name and with no changed headers" do
        should "raise an error" do
          assert_raise ArgumentError do
            @s3.copy_key('test', 'test.txt')
          end
        end
      end

      context "with a delayed error" do
        setup {
          xml = load_fixture('s3/copy_failure')
          response = stub('Http Response', :is_a? => true, :code => 200, :body => xml)
          @s3.expects(:send_s3_request).returns(response)
        }

        should "raise an error" do
          assert_raise Awsum::Error do
            @s3.copy_key('test', 'test.txt', 'test2')
          end
        end
      end
    end

    context "a key" do
      setup {
        @key = Awsum::S3::Key.new(@s3, 'test', 'test.txt', Time.now, 'XXXXX', 234, 'AAAAAA', 'STANDARD')
      }

      should "be able to delete itself" do
        response = stub('Http Response', :is_a? => true)
        @s3.expects(:send_s3_request).returns(response)

        assert @key.delete
      end

      should "be able to copy itself to a different name" do
        response = stub('Http Response', :is_a? => true, :body => '')
        @s3.expects(:send_s3_request).returns(response)

        assert @key.copy('test2.txt')
      end

      should "be able to rename itself" do
        response = stub('Http Response', :is_a? => true, :body => '')
        @s3.expects(:send_s3_request).returns(response).times(2)

        assert @key.rename('test2.txt')
      end

      should "be able to move itself" do
        response = stub('Http Response', :is_a? => true, :body => '')
        @s3.expects(:send_s3_request).returns(response).times(2)

        assert @key.move('test2.txt')
      end

      should "be able to copy itself to a new bucket" do
        response = stub('Http Response', :is_a? => true, :body => '')
        @s3.expects(:send_s3_request).returns(response)

        assert @key.copy_to('another_bucket')
      end

      should "be able to move itself to a new bucket" do
        response = stub('Http Response', :is_a? => true, :body => '')
        @s3.expects(:send_s3_request).returns(response).times(2)

        assert @key.move_to('another_bucket')
      end
    end
  end
end
