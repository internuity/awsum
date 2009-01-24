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
  # All calls to EC2 can be done directly in this class, or through a more object oriented way through the various returned classes
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
  # If you need any of this functionality, please consider getting involved and help complete this library.
  class S3
    include Awsum::Requestable

    # Create an new S3 instance
    #
    # The access_key and secret_key are both required to do any meaningful work.
    #
    # If you want to get these keys from environment variables, you can do that in your code as follows:
    #   s3 = Awsum::S3.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    def initialize(access_key = nil, secret_key = nil)
      @access_key = access_key
      @secret_key = secret_key
    end

    def create_bucket(bucket_name)
      raise ArgumentError.new('Bucket name cannot be in an ip address style') if bucket_name =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/
      raise ArgumentError.new('Bucket name can only have lowercase letters, numbers, periods (.), underscores (_) and dashes (-)') unless bucket_name =~ /^[a-z\d][-a-z\d._]+[a-z\d._]$/
      raise ArgumentError.new('Bucket name cannot contain a dash (-) next to a period (.)') if bucket_name =~ /\.-|-\./
      raise ArgumentError.new('Bucket name must be between 3 and 63 characters') if bucket_name.size < 3 || bucket_name.size > 63
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
