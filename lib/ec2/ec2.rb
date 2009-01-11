require 'cgi'
require 'base64'
require 'openssl'
require 'ec2/image'

module Awsum
  class Ec2 < Awsum::Requestable

    def host
      'ec2.amazonaws.com'
    end

    def initialize(access_key, secret_key)
      @access_key = access_key
      @secret_key = secret_key
    end

    # Retrieve a list of available images (Maps to DescribeImages)
    # Options:
    # * <tt>:image_ids</tt>: array of image id's, default: []
    # * <tt>:owners</tt>: array of owner id's, default: []
    # * <tt>:executable_by</tt>: array of user id's who have executable permission, #   default: []
    def images(options = {})
      options = {:image_ids => [], :owners => [], :executable_by => []}.merge(options)
      action = 'DescribeImages'
      params = {
          'Action'           => action,
        }
      #Add options
      params.merge!(array_to_params(options[:image_ids], "ImageId"))
      params.merge!(array_to_params(options[:owners], "Owner"))
      params.merge!(array_to_params(options[:executable_by], "ExecutableBy"))

      response = send_request(params)
      parser = Awsum::Ec2::ImageParser.new
      parser.parse(response.body)
    end

    # Retrieve a single image
    def image(image_id)
      arr = images(:image_ids => [image_id])
      arr.size > 0 ? arr[0] : nil
    end
  end
end
