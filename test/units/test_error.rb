require File.expand_path('../helper', File.dirname(__FILE__))

class ErrorTest < Test::Unit::TestCase
  context "A request to EC2" do
    setup {
      @ec2 = Awsum::Ec2.new('abc', 'xyz')
    }

    context "a raised error" do
      setup {
        xml = load_fixture('ec2/invalid_request_error')
        response = stub('Http Response', :body => xml, :code => 400)
        @ec2.expects(:process_request).with{|method, uri| @uri = uri}.returns(response)

        begin
          @ec2.images
        rescue Awsum::Error => e
          @error = e
        end
      }

      should "have the correct response code" do
        assert_equal 400, @error.response_code
      end

      should "have the correct code" do
        assert_equal 'InvalidRequest', @error.code
      end

      should "have the correct message" do
        assert_equal 'The request received was invalid.', @error.message
      end

      should "have the correct request id" do
        assert_equal '7cbacf61-c7df-468a-8130-cf5d659f8144', @error.request_id
      end

      should "return error info in inspect" do 
        assert_equal '#<Awsum::Error response_code=400 code=InvalidRequest request_id=7cbacf61-c7df-468a-8130-cf5d659f8144 message=The request received was invalid.>', @error.inspect
      end
    end

    context "with an invalid request" do
      setup {
        xml = load_fixture('ec2/invalid_request_error')
        response = stub('Http Response', :body => xml, :code => 400)
        @ec2.expects(:process_request).with{|method, uri| @uri = uri}.returns(response)
      }

      should "raise an error" do
        assert_raise Awsum::Error do
          @ec2.images
        end
      end
    end
  end

  context "A request to S3" do
    setup {
      @s3 = Awsum::S3.new('abc', 'xyz')
    }

    context "with an invalid signature" do
      setup {
        xml = load_fixture('s3/invalid_request_signature')
        response = stub('Http Response', :body => xml, :code => 403)
        @s3.expects(:process_request).yields(response)

        begin
          @s3.create_key('test', 'test.txt', 'some data')
        rescue Awsum::Error => e
          @error = e
        end
      }

      should "have the correct response code" do
        assert_equal 403, @error.response_code
      end

      should "have the correct code" do
        assert_equal 'SignatureDoesNotMatch', @error.code
      end

      should "have the correct message" do
        assert_equal 'The request signature we calculated does not match the signature you provided. Check your key and signing method.', @error.message
      end

      should "have the correct request id" do
        assert_equal '508F513C9D42C30E', @error.request_id
      end

      should "have additional data" do 
        assert @error.additional.is_a?(Hash)
      end

      should "have the string to sign" do 
        assert_equal '50 55 54 0a 59 57 59 34 4d 47 4a 6c 4d 6d 55 32 5a 44 59 35 4e 32 59 79 4f 57 45 35 5a 44 67 31 59 6a 67 33 59 54 51 35 4f 54 6b 79 4d 44 55 3d 0a 61 70 70 6c 69 63 61 74 69 6f 6e 2f 78 2d 77 77 77 2d 66 6f 72 6d 2d 75 72 6c 65 6e 63 6f 64 65 64 0a 54 75 65 2c 20 32 37 20 4a 61 6e 20 32 30 30 39 20 30 35 3a 31 38 3a 30 36 20 2b 30 32 30 30 0a 2f 61 77 73 75 6d 2d 74 65 73 74 2d 62 75 63 6b 65 74 2f 74 65 73 74 31 2e 74 78 74', @error.additional['StringToSignBytes']
      end
    end
  end
end
