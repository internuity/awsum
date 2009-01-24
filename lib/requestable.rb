require 'net/https'
require 'uri'
require 'error'
require 'cgi'
require 'base64'
require 'openssl'

module Awsum
  module Requestable #:nodoc:

  private
    # Sends a request with query parameters
    #
    # Used for EC2 requests
    def send_query_request(params)
      standard_options = {
        'AWSAccessKeyId'   => @access_key,
        'Version'          => API_VERSION,
        'Timestamp'        => Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
        'SignatureVersion' => SIGNATURE_VERSION,
        'SignatureMethod'  => 'HmacSHA256'
      }
      params = standard_options.merge(params)

      #Put parameters into query string format
      params_string = params.delete_if{|k,v| v.nil?}.sort{|a,b| a[0].to_s <=> b[0].to_s}.collect{|key, val| "#{CGI::escape(key.to_s)}=#{CGI::escape(val.to_s)}"}.join('&')
      params_string.gsub!('+', '%20')

      #Create request signature
      signature_string = "GET\n#{host}\n/\n#{params_string}"
      signature = sign(signature_string, 'sha256')

      #Attach signature to query string
      params_string << "&Signature=#{CGI::escape(signature)}"

      #TODO: Allow secure/non-secure
      Net::HTTP.version_1_1
      url = URI.parse("https://#{host}/?#{params_string}")
      url.scheme = 'https'
      url.port = 443

      headers = {}
      request = Net::HTTP::Get.new(url.path)

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      puts "URL: #{url}" if ENV['DEBUG']
      response = http.send_request('GET', url.request_uri, nil, headers)
      puts "Response:\n#{response.code}\n#{response.body}" if ENV['DEBUG']
      if response.is_a?(Net::HTTPSuccess)
        response
      else
        raise Awsum::Error.new(response)
      end
    end

    # Converts an array of paramters into <param_name>.<num> format
    def array_to_params(arr, param_name)
      arr = [arr] unless arr.is_a?(Array)
      params = {}
      arr.each_with_index do |value,i|
        params["#{param_name}.#{i+1}"] = value
      end
      params
    end

    # Sign a string with a digest, wrap in HMAC digest and base64 encode
    #
    # ===Returns
    # base64 encoded string with newlines removed
    def sign(string, digest = 'sha1')
      Base64::encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new(digest), @secret_key, string)).gsub(/\n/, '')
    end
  end
end
