require 'spec_helper'

module Awsum
  describe Requestable do
    describe "ec2 requests" do
      subject {
        Class.new {
          include Awsum::Requestable

          def initialize
            @access_key = 'ABCDEF'
            @secret_key = '123456'
          end

          def host
            'test.amazonaws.com'
          end
        }.new
      }

      describe "#send_query_request" do
        it "should generate the correct request uri" do
          FakeWeb.register_uri(:get, 'https://test.amazonaws.com/?AWSAccessKeyId=ABCDEF&Action=DescribeImages&ImageId.1=ami-1234567&SignatureMethod=HmacSHA256&SignatureVersion=2&Timestamp=2009-01-23T03%3A34%3A38.000Z&Version=2010-06-15&Signature=ZkjqlJRngvT4sITa50ZODqeYn%2FMBBDNtFhFf6ucz7QI%3D', :body => '', :status => 200)

          subject.send(:send_query_request, {'Action' => 'DescribeImages', 'ImageId.1' => 'ami-1234567', 'Timestamp' => '2009-01-23T03:34:38.000Z'})
        end
      end
    end

    # These test are taken directly from Amazon's examples at
    # http://docs.amazonwebservices.com/AmazonS3/2006-03-01/RESTAuthentication.html
    describe "an S3" do
      subject {
        Class.new {
          include Awsum::Requestable

          def initialize
            @access_key = '0PN5J17HBGZHT7JJ3X82'
            @secret_key = 'uV3F3YluFJax1cknvbcGwgjvx4QpvB+leU8dUj2o'
          end

          def host
            's3.amazonaws.com'
          end
        }.new
      }

      describe "GET request" do
        it "should generate the correct authorization header" do
          subject.should_receive(:process_request).with { |method, uri, headers, data|
            headers['authorization'].should == 'AWS 0PN5J17HBGZHT7JJ3X82:xXjDGYUmKxnwqr5KXNPGldn5LbA='
          }

          subject.send(:send_s3_request, 'GET', {:bucket => 'johnsmith', :key => '/photos/puppy.jpg', :headers => {'Date' => 'Tue, 27 Mar 2007 19:36:42 +0000'}})
        end
      end

      describe "PUT request" do
        it "should generate the correct authorization header" do
          subject.should_receive(:process_request).with { |method, uri, headers, data|
            headers['authorization'].should == 'AWS 0PN5J17HBGZHT7JJ3X82:hcicpDDvL9SsO6AkvxqmIWkmOuQ='
          }

          subject.send(:send_s3_request, 'PUT', {:bucket => 'johnsmith', :key => '/photos/puppy.jpg', :headers => {'Date' => 'Tue, 27 Mar 2007 21:15:45 +0000', 'Content-Type' => 'image/jpeg', 'Content-Length' => 94328}})
        end
      end

      describe "GET request to list bucket contents" do
        it "should generate the correct authorization header" do
          subject.should_receive(:process_request).with { |method, uri, headers, data|
            headers['authorization'].should == 'AWS 0PN5J17HBGZHT7JJ3X82:thdUi9VAkzhkniLj96JIrOPGi0g='
          }

          subject.send(:send_s3_request, 'GET', {:bucket => 'johnsmith', :key => '', :parameters => {'acl' => nil}, :headers => {'Date' => 'Tue, 27 Mar 2007 19:44:46 +0000'}})
        end
      end

      describe "DELETE request" do
        it "should generate the correct authorization header" do
          subject.should_receive(:process_request).with { |method, uri, headers, data|
            headers['authorization'].should == 'AWS 0PN5J17HBGZHT7JJ3X82:k3nL7gH3+PadhTEVn5Ip83xlYzk='
          }

          subject.send(:send_s3_request, 'DELETE', {:bucket => 'johnsmith', :key => '/photos/puppy.jpg', :headers => {'Date' => 'Tue, 27 Mar 2007 21:20:27 +0000', 'User-Agent' => 'dotnet', 'x-amz-date' => 'Tue, 27 Mar 2007 21:20:26 +0000'}})
        end
      end

      describe "PUT request to upload" do
        it "should generate the correct authorization header" do
          subject.should_receive(:process_request).with { |method, uri, headers, data|
            headers['authorization'].should == 'AWS 0PN5J17HBGZHT7JJ3X82:C0FlOtU8Ylb9KDTpZqYkZPX91iI='
          }

          subject.send(:send_s3_request, 'PUT', {:bucket => 'static.johnsmith.net', :key => '/db-backup.dat.gz', :headers => {'Date' => 'Tue, 27 Mar 2007 21:06:08 +0000', 'User-Agent' => 'curl/7.15.5', 'x-amz-acl' => 'public-read', 'content-type' => 'application/x-download', 'Content-MD5' => '4gJE4saaMU4BqNR0kLY+lw==', 'X-Amz-Meta-ReviewedBy' => ['joe@johnsmith.net', 'jane@johnsmith.net'], 'X-Amz-Meta-FileChecksum' => '0x02661779', 'X-Amz-Meta-ChecksumAlgorithm' => 'crc32', 'Content-Disposition' => 'attachment; filename=database.dat', 'Content-Encoding' => 'gzip', 'Content-Length' => '5913339'}})
        end
      end

      describe "GET request to list all buckets" do
        it "should generate the correct authorization header" do
          subject.should_receive(:process_request).with { |method, uri, headers, data|
            headers['authorization'].should == 'AWS 0PN5J17HBGZHT7JJ3X82:Db+gepJSUbZKwpx1FR0DLtEYoZA='
          }

          subject.send(:send_s3_request, 'GET', {:bucket => '', :key => '', :headers => {'Date' => 'Wed, 28 Mar 2007 01:29:59 +0000'}})
        end
      end

      describe "GET request with unicode keys" do
        it "should generate the correct authorization header" do
          subject.should_receive(:process_request).with { |method, uri, headers, data|
            headers['authorization'].should == 'AWS 0PN5J17HBGZHT7JJ3X82:dxhSBHoI6eVSPcXJqEghlUzZMnY='
          }

          subject.send(:send_s3_request, 'GET', {:bucket => 'dictionary', :key => '/fran%C3%A7ais/pr%c3%a9f%c3%a8re', :headers => {'Date' => 'Wed, 28 Mar 2007 01:49:49 +0000'}})
        end
      end

      describe "signed request" do
        it "should generate the correct signed URI" do
          signed_request = subject.send(:generate_s3_signed_request_url, 'GET', 'johnsmith', '/photos/puppy.jpg', 1175139620)
          signed_request.should == 'http://johnsmith.s3.amazonaws.com/photos/puppy.jpg?AWSAccessKeyId=0PN5J17HBGZHT7JJ3X82&Signature=rucSbH0yNEcP9oM2XNlouVI3BH4%3D&Expires=1175139620'
        end
      end
    end
  end
end
