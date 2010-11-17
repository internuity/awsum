require 'base64'
require 'cgi'
require 'digest/md5'
require 'openssl'
require 'time'
require 'uri'
require 'awsum/error'

require 'net/https'
require 'awsum/net_fix'

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
      params_string = params.delete_if{|k,v| v.nil?}.sort{|a,b|
        a[0].to_s <=> b[0].to_s
      }.collect{|key, val|
        "#{CGI::escape(key.to_s)}=#{CGI::escape(val.to_s)}"
      }.join('&')
      params_string.gsub!('+', '%20')

      #Create request signature
      signature_string = "GET\n#{host}\n/\n#{params_string}"
      signature = sign(signature_string, 'sha256')

      #Attach signature to query string
      params_string << "&Signature=#{CGI::escape(signature)}"

      url = "https://#{host}/?#{params_string}"
      response = process_request('GET', url)
      if response.is_a?(Net::HTTPSuccess)
        response
      else
        raise Awsum::Error.new(response)
      end
    end

    # Sends a full request including headers and possible post data
    #
    # Used for S3 requests
    def send_s3_request(method = 'GET', options = {}, &block)
      bucket = options[:bucket] || ''
      key = options[:key] || ''
      parameters = options[:parameters] || {}
      data = options[:data]
      headers = {}
      (options[:headers] || {}).each { |k,v| headers[k.downcase] = v }

      #Add the host header
      host_name = "#{bucket}#{bucket.blank? ? '' : '.'}#{host}"
      headers['host'] = host_name

      # Ensure required headers are in place
      if !data.nil? && headers['content-md5'].nil?
        if data.respond_to?(:read)
          if data.respond_to?(:rewind)
            digest = Digest::MD5.new
            while chunk = data.read(1024 * 1024)
              digest << chunk
            end
            data.rewind

            headers['content-md5'] = Base64::encode64(digest.digest).gsub(/\n/, '')
          end
        else
          headers['content-md5'] = Base64::encode64(Digest::MD5.digest(data)).gsub(/\n/, '')
        end
      end
      if !data.nil? && headers['content-length'].nil?
        headers['content-length'] = (data.respond_to?(:lstat) ? data.lstat.size : data.size).to_s
      end
      headers['date'] = Time.now.rfc822 if headers['date'].nil?
      headers['content-type'] ||= ''
      if !data.nil?
        headers['expect'] = '100-continue'
      end

      signature_string = generate_rest_signature_string(method, bucket, key, parameters, headers)
      puts "signature_string: \n#{signature_string}\n\n" if ENV['DEBUG']

      signature = sign(signature_string)

      headers['authorization'] = "AWS #{@access_key}:#{signature}"

      url = "https://#{host_name}#{key[0..0] == '/' ? '' : '/'}#{key}#{parameters.size == 0 ? '' : "?#{parameters.collect{|k,v| v.nil? ? k.to_s : "#{CGI::escape(k.to_s)}=#{CGI::escape(v.to_s)}"}.join('&')}"}"

      process_request(method, url, headers, data) do |response|
        if response.is_a?(Net::HTTPSuccess)
          if block_given?
            block.call(response)
          else
            response
          end
        else
          raise Awsum::Error.new(response)
        end
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

      signature_string = "#{method}\n#{headers['content-md5']}\n#{headers['content-type']}\n#{headers['x-amz-date'].nil? ? headers['date'] : ''}\n#{canonicalized_amz_headers}#{canonicalized_amz_headers.blank? ? '' : "\n"}#{canonicalized_resource}"
    end

    def generate_s3_signed_request_url(method, bucket, key, expires = nil)
      signature_string = generate_rest_signature_string(method, bucket, key, {}, {'date' => expires})
      signature = sign(signature_string)
      "http://#{bucket}#{bucket.blank? ? '' : '.'}#{host}#{key[0..0] == '/' ? '' : '/'}#{key}?AWSAccessKeyId=#{@access_key}&Signature=#{CGI::escape(signature)}&Expires=#{expires}"
    end

    def process_request(method, url, headers = {}, data = nil, &block)
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
        case method.upcase
          when 'GET'
            request = Net::HTTP::Get.new("#{uri.path}#{"?#{uri.query}" if uri.query}")
          when 'POST'
            request = Net::HTTP::Post.new("#{uri.path}#{"?#{uri.query}" if uri.query}")
          when 'PUT'
            request = Net::HTTP::Put.new("#{uri.path}#{"?#{uri.query}" if uri.query}")
          when 'DELETE'
            request = Net::HTTP::Delete.new("#{uri.path}#{"?#{uri.query}" if uri.query}")
          when 'HEAD'
            request = Net::HTTP::Head.new("#{uri.path}#{"?#{uri.query}" if uri.query}")
        end
        request.initialize_http_header(headers)

        unless data.nil?
          if data.respond_to?(:read)
            request.body_stream = data
          else
            request.body = data
          end
        end

        if block_given?
          http.request(request) do |response|
            handle_response response, &block
          end
        else
          response = http.request(request)
          handle_response response
        end
      end
    end

    def handle_response(response, &block)
      case response
        when Net::HTTPSuccess
          if block_given?
            block.call(response)
          else
            response
          end
        when Net::HTTPMovedPermanently, Net::HTTPFound, Net::HTTPTemporaryRedirect
          new_uri = URI.parse(response['location'])
          uri.host = new_uri.host
          uri.path = "#{new_uri.path}#{uri.path unless uri.path = '/'}"
          process_request(method, uri.to_s, headers, data, &block)
        else
          response
      end
    end

    # Converts an array of paramters into <param_name>.<num> format
    def array_to_params(arr, param_name)
      arr = [arr].flatten
      params = {}
      arr.each_with_index do |value, i|
        if value.respond_to?(:keys)
          value.each do |key, val|
            param_key = "#{param_name}.#{i+1}.#{parameterize(key)}"
            if val.is_a?(Array) || val.respond_to?(:keys)
              params.merge! array_to_params(val, param_key)
            else
              params[param_key] = val
            end
          end
        else
          params["#{param_name}.#{i+1}"] = value
        end
      end
      params
    end

    def parameterize(string)
      string.to_s.split(/_/).map{ |w| w.downcase.sub(/^(.)/){ $1.upcase } }.join
    end

    def parse_filters(filters, tags)
      result = []
      if filters
        filters.each do |k,v|
          values = v.is_a?(Array) ? v : [v]
          result << {:name => k, :value => values}
        end
      end
      if tags
        tags.each do |k,v|
          values = v.is_a?(Array) ? v : [v]
          result << {:name => "tag:#{k}", :value => values}
        end
      end
      if result.size > 0
        array_to_params(result, "Filter")
      else
        {}
      end
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
