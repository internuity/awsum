require File.expand_path('../helper', File.dirname(__FILE__))

class RequestableTest < Test::Unit::TestCase
  #include Awsum::Requestable so we can test the private methods directly
  include Awsum::Requestable

  context "Mock HTTP calls: " do
    setup {
      @http = mock('HTTP', :use_ssl= => nil, :verify_mode= => nil)
      @response = mock('HTTP Response', :is_a? => true)
      Net::HTTP.expects(:new).returns(@http)
    }

    context "A call to send_query_request" do
      setup {
        @access_key = 'ABCDEF'
        @secret_key = '123456'
        @host = 'test.amazonaws.com'
        @http.expects(:send_request).with{|method, uri, data, headers| 
          uri == '/?AWSAccessKeyId=ABCDEF&Action=DescribeImages&ImageId.1=ami-1234567&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2009-01-23T03%3A34%3A38.000Z&Version=2008-12-01&Signature=Da66foYzsBTzMoCgCMBaUJrr4ha3NpWEWZ%2BHxl5h5eg%3D'
        }.returns(@response)

        send_query_request({'Action' => 'DescribeImages', 'ImageId.1' => 'ami-1234567', 'Timestamp' => '2009-01-23T03:34:38.000Z'})
      }

      should "pass" do
        assert true
      end
    end

    # These test are taken directly from Amazon's examples at 
    # http://docs.amazonwebservices.com/AmazonS3/2006-03-01/RESTAuthentication.html
    context "AWS S3 Authentication examples: " do
      setup {
        @access_key = '0PN5J17HBGZHT7JJ3X82'
        @secret_key = 'uV3F3YluFJax1cknvbcGwgjvx4QpvB+leU8dUj2o'
        @host = 's3.amazonaws.com'
      }

      context "Example Object GET" do
        setup {
          method = 'GET'
          key = '/photos/puppy.jpg'
          bucket = 'johnsmith'
          date = 'Tue, 27 Mar 2007 19:36:42 +0000'
          headers = {
            'Date' => date
          }

          @http.expects(:send_request).with{|method, uri, data, headers| 
            headers['Authorization'] == 'AWS 0PN5J17HBGZHT7JJ3X82:xXjDGYUmKxnwqr5KXNPGldn5LbA='
          }.returns(@response)

          send_s3_request(method, bucket, key, {}, headers)
        }

        should "pass" do
          assert true
        end
      end

      context "Example Object PUT" do
        setup {
          method = 'PUT'
          key = '/photos/puppy.jpg'
          bucket = 'johnsmith'
          date = 'Tue, 27 Mar 2007 21:15:45 +0000'
          headers = {
            'Date' => date,
            'Content-Type' => 'image/jpeg',
            'Content-Length' => 94328
          }

          @http.expects(:send_request).with{|method, uri, data, headers| 
            headers['Authorization'] == 'AWS 0PN5J17HBGZHT7JJ3X82:hcicpDDvL9SsO6AkvxqmIWkmOuQ='
          }.returns(@response)

          send_s3_request(method, bucket, key, {}, headers)
        }

        should "pass" do
          assert true
        end
      end

      context "Example List" do
        setup {
          method = 'GET'
          key = ''
          parameters = {'acl' => nil}
          bucket = 'johnsmith'
          date = 'Tue, 27 Mar 2007 19:44:46 +0000'
          headers = {
            'Date' => date
          }

          @http.expects(:send_request).with{|method, uri, data, headers| 
            headers['Authorization'] == 'AWS 0PN5J17HBGZHT7JJ3X82:thdUi9VAkzhkniLj96JIrOPGi0g='
          }.returns(@response)

          send_s3_request(method, bucket, key, parameters, headers)
        }

        should "pass" do
          assert true
        end
      end

      context "Example Delete" do
        setup {
          method = 'DELETE'
          key = '/photos/puppy.jpg'
          parameters = {}
          bucket = 'johnsmith'
          date = 'Tue, 27 Mar 2007 21:20:27 +0000'
          headers = {
            'Date' => date,
            'User-Agent' => 'dotnet',
            'x-amz-date' => 'Tue, 27 Mar 2007 21:20:26 +0000'
          }

          @http.expects(:send_request).with{|method, uri, data, headers| 
            headers['Authorization'] == 'AWS 0PN5J17HBGZHT7JJ3X82:k3nL7gH3+PadhTEVn5Ip83xlYzk='
          }.returns(@response)

          send_s3_request(method, bucket, key, parameters, headers)
        }

        should "pass" do
          assert true
        end
      end

      context "Example Upload" do
        setup {
          method = 'PUT'
          key = '/db-backup.dat.gz'
          parameters = {}
          bucket = 'static.johnsmith.net'
          date = 'Tue, 27 Mar 2007 21:06:08 +0000'
          headers = {
            'Date' => date,
            'User-Agent' => 'curl/7.15.5',
            'x-amz-acl' => 'public-read',
            'content-type' => 'application/x-download',
            'Content-MD5' => '4gJE4saaMU4BqNR0kLY+lw==',
            'X-Amz-Meta-ReviewedBy' => ['joe@johnsmith.net', 'jane@johnsmith.net'],
            'X-Amz-Meta-FileChecksum' => '0x02661779',
            'X-Amz-Meta-ChecksumAlgorithm' => 'crc32',
            'Content-Disposition' => 'attachment; filename=database.dat',
            'Content-Encoding' => 'gzip',
            'Content-Length' => '5913339'
          }

          @http.expects(:send_request).with{|method, uri, data, headers| 
            headers['Authorization'] == 'AWS 0PN5J17HBGZHT7JJ3X82:C0FlOtU8Ylb9KDTpZqYkZPX91iI='
          }.returns(@response)

          send_s3_request(method, bucket, key, parameters, headers)
        }

        should "pass" do
          assert true
        end
      end

      context "Example List All My Buckets" do
        setup {
          method = 'GET'
          key = ''
          parameters = {}
          bucket = ''
          date = 'Wed, 28 Mar 2007 01:29:59 +0000'
          headers = {
            'Date' => date
          }

          @http.expects(:send_request).with{|method, uri, data, headers| 
            headers['Authorization'] == 'AWS 0PN5J17HBGZHT7JJ3X82:Db+gepJSUbZKwpx1FR0DLtEYoZA='
          }.returns(@response)

          send_s3_request(method, bucket, key, parameters, headers)
        }

        should "pass" do
          assert true
        end
      end

      context "Example Unicode Keys" do
        setup {
          method = 'GET'
          key = '/fran%C3%A7ais/pr%c3%a9f%c3%a8re'
          parameters = {}
          bucket = 'dictionary'
          date = 'Wed, 28 Mar 2007 01:49:49 +0000'
          headers = {
            'Date' => date
          }

          @http.expects(:send_request).with{|method, uri, data, headers| 
            headers['Authorization'] == 'AWS 0PN5J17HBGZHT7JJ3X82:dxhSBHoI6eVSPcXJqEghlUzZMnY='
          }.returns(@response)

          send_s3_request(method, bucket, key, parameters, headers)
        }

        should "pass" do
          assert true
        end
      end
    end
  end

  context "AWS S3 Authentication examples: " do
    setup {
      @access_key = '0PN5J17HBGZHT7JJ3X82'
      @secret_key = 'uV3F3YluFJax1cknvbcGwgjvx4QpvB+leU8dUj2o'
      @host = 's3.amazonaws.com'
    }

    context "Example Query String Request Authentication" do
      setup {
        method = 'GET'
        key = '/photos/puppy.jpg'
        parameters = {}
        bucket = 'johnsmith'
        expires = 1175139620
        headers = {}
        @signed_request = generate_s3_signed_request_url(method, bucket, key, expires)
      }

      should "pass" do
        assert_equal 'http://johnsmith.s3.amazonaws.com/photos/puppy.jpg?AWSAccessKeyId=0PN5J17HBGZHT7JJ3X82&Signature=rucSbH0yNEcP9oM2XNlouVI3BH4%3D&Expires=1175139620', @signed_request
      end
    end
  end

  #Host helper
  def host
    @host
  end
end
