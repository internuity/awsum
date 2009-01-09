require 'net/https'
require 'uri'

module Awsum
  class Requestable
    API_VERSION = '2008-12-01'
    SIGNATURE_VERSION = 2

    def send_request(params)
      standard_options = {
        'AWSAccessKeyId'   => @access_key,
        'Version'          => API_VERSION,
        'Timestamp'        => Time.now.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
        'SignatureVersion' => SIGNATURE_VERSION,
        'SignatureMethod'  => 'HmacSHA256'
      }
      params = standard_options.merge(params)

      #Put parameters into query string format
      params_string = params.sort{|a,b| a[0] <=> b[0].to_s}.collect{|key, val| "#{CGI::escape(key)}=#{CGI::escape(val.to_s)}"}.join('&')
      params_string.gsub!('+', '%20')

      #Create request signature
      signature_string = "GET\n#{host}\n/\n#{params_string}"
      signature = Base64::encode64(OpenSSL::HMAC.digest(OpenSSL::Digest::Digest.new('sha256'), @secret_key, signature_string)).gsub(/\n/, '')

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

      response = http.send_request('GET', url.request_uri, nil, headers)
    end

    def array_to_params(arr, param_name)
      params = {}
      arr.each_with_index do |value,i|
        params["#{param_name}.#{i+1}"] = value
      end
      params
    end
  end
end
