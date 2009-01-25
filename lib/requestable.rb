require 'base64'
require 'cgi'
require 'digest/md5'
require 'error'
require 'net/https'
require 'openssl'
require 'time'
require 'uri'

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

      url = "https://#{host}/?#{params_string}"
      response = process_request('GET', url)
      puts "URL: #{url}" if ENV['DEBUG']
      puts "Response:\n#{response.code}\n#{response.body}" if ENV['DEBUG']
      if response.is_a?(Net::HTTPSuccess)
        response
      else
        raise Awsum::Error.new(response)
      end
    end

    # Sends a full request including headers and possible post data
    #
    # Used for S3 requests
    def send_s3_request(method, bucket, key = '', parameters = {}, headers = {}, data = nil)
      # Ensure required headers are in place
      if !data.nil? && headers['Content-MD5'].nil?
        headers['Content-MD5'] = Base64::encode64(Digest::MD5.digest(data))
      end
      headers['Date'] = Time.now.rfc822 if headers['Date'].nil?

      signature_string = generate_rest_signature_string(method, bucket, key, parameters, headers)
      #puts "signature_string: \n#{signature_string}\n\n"

      signature = sign(signature_string)

      headers['Authorization'] = "AWS #{@access_key}:#{signature}"

      response = process_request(method, "https://#{bucket}#{bucket.blank? ? '' : '.'}#{host}#{key[0..0] == '/' ? '' : '/'}#{key}#{parameters.size == 0 ? '' : "?#{parameters.collect{|k,v| v.nil? ? k.to_s : "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}"}.join('&')}"}", headers, data)

      puts "URL: #{url}" if ENV['DEBUG']
      puts "Response:\n#{response.code}\n#{response.body}" if ENV['DEBUG']
      if response.is_a?(Net::HTTPSuccess)
        response
      else
        raise Awsum::Error.new(response)
      end
    end

    def generate_rest_signature_string(method, bucket, key, parameters, headers)
      canonicalized_amz_headers = headers.sort{|a,b| a[0].to_s.downcase <=> b[0].to_s.downcase }.collect{|k, v| "#{k.to_s.downcase}:#{(v.is_a?(Array) ? v.join(',') : v).gsub(/\n/, ' ')}" if k =~ /\Ax-amz-/i }.compact.join("\n")
      canonicalized_resource = "#{bucket.blank? ? '' : '/'}#{bucket}#{key[0..0] == '/' ? '' : '/'}#{key}"
      ['acl', 'torrent', 'logging', 'location'].each do |sub_resource|
        if parameters.has_key?(sub_resource)
          canonicalized_resource << "?#{sub_resource}"
          break
        end
      end

      content_type = headers[headers.collect{|k,v| k if k =~ /\Acontent-type\z/i}.compact[0]]
      content_md5  = headers[headers.collect{|k,v| k if k =~ /\Acontent-md5\z/i}.compact[0]]
      amz_date     = headers[headers.collect{|k,v| k if k =~ /\Ax-amz-date\z/i}.compact[0]]

      signature_string = "#{method}\n#{content_md5}\n#{content_type}\n#{amz_date.nil? ? headers['Date'] : ''}\n#{canonicalized_amz_headers}#{canonicalized_amz_headers.blank? ? '' : "\n"}#{canonicalized_resource}"
    end

    def generate_s3_signed_request_url(method, bucket, key, expires = nil)
      signature_string = generate_rest_signature_string(method, bucket, key, {}, {'Date' => expires})
      signature = sign(signature_string)
      "http://#{bucket}#{bucket.blank? ? '' : '.'}#{host}#{key[0..0] == '/' ? '' : '/'}#{key}?AWSAccessKeyId=#{@access_key}&Signature=#{CGI::escape(signature)}&Expires=#{expires}"
    end

    def process_request(method, url, headers = {}, data = nil)
      #TODO: Allow secure/non-secure
      uri = URI.parse(url)
      uri.scheme = 'https'
      uri.port = 443

      #puts uri.to_s

      Net::HTTP.version_1_1
      con = Net::HTTP.new(uri.host, uri.port)
      con.use_ssl = true
      con.verify_mode = OpenSSL::SSL::VERIFY_NONE
      con.start do |http|
        request = Net::HTTP::Get.new("#{uri.path}#{"?#{uri.query}" if uri.query}")

        response = http.request(request)

        #puts response.inspect
        #puts response.code
        #response.each_header do |key,val|
        #  puts "   #{key} = #{val}"
        #end
        #puts response.body
        #puts

        case response
          when Net::HTTPSuccess
            response
          when Net::HTTPRedirection
            new_uri = URI.parse(response['Location'])
            uri.host = new_uri.host
            uri.path = "#{new_uri.path}#{uri.path unless uri.path = '/'}"
            response = process_request(method, uri.to_s, headers, data)
        end
        response
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
