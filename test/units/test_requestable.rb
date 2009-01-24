require File.expand_path('../helper', File.dirname(__FILE__))

class RequestableTest < Test::Unit::TestCase
  #include Awsum::Requestable so we can test the private methods directly
  include Awsum::Requestable

  def setup
    @access_key = 'ABCDEF'
    @secret_key = '123456'
  end

  context "A call to send_query_request" do
    setup {
      http = mock('HTTP', :use_ssl= => nil, :verify_mode= => nil)
      response = mock('HTTP Response', :is_a? => true)
      http.expects(:send_request).with{|method, uri, data, headers| 
        uri == '/?AWSAccessKeyId=ABCDEF&Action=DescribeImages&ImageId.1=ami-1234567&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2009-01-23T03%3A34%3A38.000Z&Version=2008-12-01&Signature=Da66foYzsBTzMoCgCMBaUJrr4ha3NpWEWZ%2BHxl5h5eg%3D'
      }.returns(response)
      Net::HTTP.expects(:new).returns(http)

      send_query_request({'Action' => 'DescribeImages', 'ImageId.1' => 'ami-1234567', 'Timestamp' => '2009-01-23T03:34:38.000Z'})
    }

    should "pass" do
      assert true
    end
  end

  #Host helper
  def host
    'test.amazonaws.com'
  end
end
