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
        http = mock('HTTP', :use_ssl= => nil, :verify_mode= => nil)
        http.expects(:send_request).with{|method, uri, data, headers| @uri = uri}.returns(response)
        Net::HTTP.expects(:new).returns(http)

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
    end

    context "with an invalid request" do
      setup {
        xml = load_fixture('ec2/invalid_request_error')
        response = stub('Http Response', :body => xml, :code => 400)
        http = mock('HTTP', :use_ssl= => nil, :verify_mode= => nil)
        http.expects(:send_request).with{|method, uri, data, headers| @uri = uri}.returns(response)
        Net::HTTP.expects(:new).returns(http)
      }

      should "raise an error" do
        assert_raise Awsum::Error do
          @ec2.images
        end
      end
    end
  end
end
