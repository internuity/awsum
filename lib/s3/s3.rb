require 's3/bucket'
require 's3/key'

module Awsum
  # Handles all interaction with Amazon S3
  #
  #--
  # TODO: Change this to S3
  # ==Getting Started
  # Create an Awsum::Ec2 object and begin calling methods on it.
  #   require 'rubygems'
  #   require 'awsum'
  #   ec2 = Awsum::Ec2.new('your access id', 'your secret key')
  #   images = ec2.my_images
  #   ...
  #
  # All calls to EC2 can be done directly in this class, or through a more 
  # object oriented way through the various returned classes
  #
  # ==Examples
  #   ec2.image('ami-ABCDEF').run
  #
  #   ec2.instance('i-123456789').volumes.each do |vol|
  #     vol.create_snapsot
  #   end
  #
  #   ec2.regions.each do |region|
  #     region.use
  #       images.each do |img|
  #         puts "#{img.id} - #{region.name}"
  #       end
  #     end
  #   end
  #
  # ==Errors
  # All methods will raise an Awsum::Error if an error is returned from Amazon
  #
  # ==Missing Methods
  # If you need any of this functionality, please consider getting involved 
  # and help complete this library.
  class S3
    include Awsum::Requestable

    # Create an new S3 instance
    #
    # The access_key and secret_key are both required to do any meaningful work.
    #
    # If you want to get these keys from environment variables, you can do that 
    # in your code as follows:
    #   s3 = Awsum::S3.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    def initialize(access_key = nil, secret_key = nil)
      @access_key = access_key
      @secret_key = secret_key
    end

    # List all the Bucket(s)
    def buckets
      response = send_s3_request
      parser = Awsum::S3::BucketParser.new(self)
      parser.parse(response.body)
    end

    # Create a new Bucket
    #
    # ===Parameters
    # * <tt>bucket_name</tt> - The name of the new bucket
    # * <tt>location</tt> <i>(optional)</i> - Can be <tt>:default</tt>, <tt>:us</tt> or <tt>:eu</tt>
    def create_bucket(bucket_name, location = :default)
      raise ArgumentError.new('Bucket name cannot be in an ip address style') if bucket_name =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
      raise ArgumentError.new('Bucket name can only have lowercase letters, numbers, periods (.), underscores (_) and dashes (-)') unless bucket_name =~ /^[\w\d][-a-z\d._]+[a-z\d._]$/
      raise ArgumentError.new('Bucket name cannot contain a dash (-) next to a period (.)') if bucket_name =~ /\.-|-\./
      raise ArgumentError.new('Bucket name must be between 3 and 63 characters') if bucket_name.size < 3 || bucket_name.size > 63

      data = nil
      if location == :eu
        data = '<CreateBucketConfiguration><LocationConstraint>EU</LocationConstraint></CreateBucketConfiguration>'
      end

      response = send_s3_request('PUT', :bucket => bucket_name, :data => data)
      response.is_a?(Net::HTTPSuccess)
    end

    def delete_bucket(bucket_name)
      response = send_s3_request('DELETE', :bucket => bucket_name)
      response.is_a?(Net::HTTPSuccess)
    end

    # List the Key(s) of a Bucket
    #
    # ===Parameters
    # * <tt>bucket_name</tt> - The name of the bucket to search for keys
    # ====Options
    # * <tt>:prefix</tt> - Limits the response to keys which begin with the indicated prefix. You can use prefixes to separate a bucket into different sets of keys in a way similar to how a file system uses folders.
    # * <tt>:marker</tt> - Indicates where in the bucket to begin listing. The list will only include keys that occur lexicographically after marker. This is convenient for pagination: To get the next page of results use the last key of the current page as the marker.
    # * <tt>:max_keys</tt> - The maximum number of keys you'd like to see in the response body. The server might return fewer than this many keys, but will not return more.
    # * <tt>:delimeter</tt> - Causes keys that contain the same string between the prefix and the first occurrence of the delimiter to be rolled up into a single result element in the CommonPrefixes collection. These rolled-up keys are not returned elsewhere in the response.
    def keys(bucket_name, options = {})
      paramters = {}
      paramters['prefix'] = options[:prefix] if options[:prefix]
      paramters['marker'] = options[:marker] if options[:marker]
      paramters['max_keys'] = options[:max_keys] if options[:max_keys]
      paramters['prefix'] = options[:prefix] if options[:prefix]

      response = send_s3_request('GET', :bucket => bucket_name, :paramters => paramters)
      parser = Awsum::S3::KeyParser.new(self)
      parser.parse(response.body)
    end

    # Create a new Key in the specified Bucket
    #
    # ===Parameters
    # * <tt>bucket_name</tt> - The name of the Bucket in which to store the Key
    # * <tt>key_name</tt> - The name/path of the Key to store
    # * <tt>data</tt> - The data to be stored in this Key
    # * <tt>headers</tt> - Standard HTTP headers to be sent along
    # * <tt>meta_headers</tt> - Meta headers to be stored along with the key
    # * <tt>acl</tt> - A canned access policy, can be one of <tt>:private</tt>, <tt>:public_read</tt>, <tt>:public_read_write</tt> or <tt>:authenticated_read</tt>
    def create_key(bucket_name, key_name, data, headers = {}, meta_headers = {}, acl = :private)
      headers = headers.dup
      meta_headers.each do |k,v|
        headers[k =~ /^x-amz-meta-/i ? k : "x-amz-meta-#{k}"] = v
      end
      headers['x-amz-acl'] = acl.to_s.gsub(/_/, '-')

      response = send_s3_request('PUT', :bucket => bucket_name, :key => key_name, :headers => headers, :data => data)
    end

#private
    #The host to make all requests against
    def host
      @host ||= 's3.amazonaws.com'
    end

    def host=(host)
      @host = host
    end
  end
end
