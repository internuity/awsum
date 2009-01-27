# Some fixes for the net/http libraries to better suppport S3
module Net
  class BufferedIO
    #Increase the default read size for streaming from the socket
    def rbuf_fill
      timeout(@read_timeout) {
        @rbuf << @io.sysread(1024 * 16)
      }
    end
  end

  class HTTPGenericRequest
    @@local_read_size = 1024 * 16

    # Added limit which can be one of :headers or :body to limit the sending of
    # a request to either the headers or the body in order to make use of 
    # 100-continue processing for S3
    def exec(sock, ver, path, limit = nil)   #:nodoc: internal use only
      if @body
        send_request_with_body sock, ver, path, @body, limit
      elsif @body_stream
        send_request_with_body_stream sock, ver, path, @body_stream, limit
      else
        write_header sock, ver, path
      end
    end

    private
    
    # Will send both headers and body unless limit is set to either 
    # :headers or :body to restrict to one
    def send_request_with_body(sock, ver, path, body, limit = nil)
      self.content_length = body.length
      delete 'Transfer-Encoding'
      supply_default_content_type
      write_header sock, ver, path unless limit == :body
      sock.write body unless limit == :headers
    end
    
    # Will send both headers and body unless limit is set to either 
    # :headers or :body to restrict to one
    #
    # Increased the default read size for streaming from local streams to 1MB
    def send_request_with_body_stream(sock, ver, path, f, limit = nil)
      unless content_length() or chunked?
        raise ArgumentError,
            "Content-Length not given and Transfer-Encoding is not `chunked'"
      end
      supply_default_content_type
      write_header sock, ver, path unless limit == :body
      if limit != :headers
        if chunked?
          while s = f.read(1024 * 1024)
            sock.write(sprintf("%x\r\n", s.length) << s << "\r\n")
          end
          sock.write "0\r\n\r\n"
        else
          while s = f.read(1024 * 1024)
            sock.write s
          end
        end
      end
    end
  end

  class HTTP < Protocol
    # Patched to handle 100-continue processing for S3
    def request(req, body = nil, &block)  # :yield: +response+
      unless started?
        start {
          req['connection'] ||= 'close'
          return request(req, body, &block)
        }
      end
      if proxy_user()
        unless use_ssl?
          req.proxy_basic_auth proxy_user(), proxy_pass()
        end
      end

      req.set_body_internal body
      begin_transport req
        # Send only the headers if a 100-continue request
        limit = ((req.is_a?(Post) || req.is_a?(Put)) && req['expect'] == '100-continue') ? :headers : nil
        req.exec @socket, @curr_http_version, edit_path(req.path), limit
        begin
          res = HTTPResponse.read_new(@socket)
          if res.is_a?(HTTPContinue) && limit && req['content-length'].to_i > 0
            req.exec @socket, @curr_http_version, edit_path(req.path), :body
          end
        end while res.kind_of?(HTTPContinue)
        res.reading_body(@socket, req.response_body_permitted?) {
          yield res if block_given?
        }
      end_transport req, res

      res
    end
  end
end
