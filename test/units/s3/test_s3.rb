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

      should "be able to delete itself with Object(s)" do
        xml = load_fixture('s3/keys')
        response = stub('Http Response', :is_a? => true, :body => xml)
        requests = sequence('requests')
        ['get objects', 'delete first object', 'delete second object', 'delete bucket'].each do |process_request|
          @s3.expects(:send_s3_request).returns(response).in_sequence(requests)
        end

        assert @bucket.delete!
      end
    end
  end

  context "Objects: " do
    context "creating an object" do
      context "with a string" do
        setup {
          response = stub('Http Response', :is_a? => true)
          @s3.expects(:send_s3_request).returns(response)
        }

        should "send data" do
          assert @s3.create_object('test', 'test.txt', 'Some text')
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
          assert @s3.create_object('test', 'test.txt', @data)
        end
      end
    end

    context "deleting an object" do
      setup {
        response = stub('Http Response', :is_a? => true)
        @s3.expects(:send_s3_request).returns(response)
      }

      should "succeed" do
        @s3.delete_object('test', 'test.txt')
      end
    end

    context "copying an object" do
      context "to a different bucket with same key" do
        setup {
          response = stub('Http Response', :is_a? => true, :body => '')
          @s3.expects(:send_s3_request).returns(response)
        }

        should "succeed" do
          assert @s3.copy_object('test', 'test.txt', 'test2')
        end
      end

      context "within the same bucket with a different key" do
        setup {
          response = stub('Http Response', :is_a? => true, :body => '')
          @s3.expects(:send_s3_request).returns(response)
        }

        should "succeed" do
          assert @s3.copy_object('test', 'test.txt', nil, 'test2.txt')
        end
      end

      context "replacing headers and meta-data" do
        setup {
          response = stub('Http Response', :is_a? => true, :body => '')
          @s3.expects(:send_s3_request).returns(response)
        }

        should "succeed" do
          assert @s3.copy_object('test', 'test.txt', nil, nil, {'New-Header' => 'two'})
        end
      end

      context "within the same bucket, with the same object and with no changed headers" do
        should "raise an error" do
          assert_raise ArgumentError do
            @s3.copy_object('test', 'test.txt')
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
            @s3.copy_object('test', 'test.txt', 'test2')
          end
        end
      end
    end

    context "an object" do
      setup {
        @object = Awsum::S3::Object.new(@s3, 'test', 'test.txt', Time.now, 'XXXXX', 234, 'AAAAAA', 'STANDARD')
      }

      should "be able to delete itself" do
        response = stub('Http Response', :is_a? => true)
        @s3.expects(:send_s3_request).returns(response)

        assert @object.delete
      end

      should "be able to copy itself to a different key" do
        response = stub('Http Response', :is_a? => true, :body => '')
        @s3.expects(:send_s3_request).returns(response)

        assert @object.copy('test2.txt')
      end

      should "be able to rename itself" do
        response = stub('Http Response', :is_a? => true, :body => '')
        @s3.expects(:send_s3_request).returns(response).times(2)

        assert @object.rename('test2.txt')
      end

      should "be able to move itself" do
        response = stub('Http Response', :is_a? => true, :body => '')
        @s3.expects(:send_s3_request).returns(response).times(2)

        assert @object.move('test2.txt')
      end

      should "be able to copy itself to a new bucket" do
        response = stub('Http Response', :is_a? => true, :body => '')
        @s3.expects(:send_s3_request).returns(response)

        assert @object.copy_to('another_bucket')
      end

      should "be able to move itself to a new bucket" do
        response = stub('Http Response', :is_a? => true, :body => '')
        @s3.expects(:send_s3_request).returns(response).times(2)

        assert @object.move_to('another_bucket')
      end

      should "be able to return it's headers" do
        response = stub('Http Response')
        @s3.expects(:send_s3_request).returns(response)

        assert @object.headers
      end

      should "be able to return it's data" do
        response = stub('Http Response', :body => 'test')
        @s3.expects(:send_s3_request).yields(response)

        assert_equal 'test', @object.data
      end

      should "be able to return it's data in chunks" do
        response = stub('Http Response')
        response.expects(:read_body).yields('test')
        @s3.expects(:send_s3_request).yields(response)

        data = ''
        @object.data do |chunk|
          data << chunk
        end

        assert_equal 'test', data
      end
    end
  end
end
