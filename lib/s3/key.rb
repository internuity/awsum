module Awsum
  class S3
    class Key
      attr_reader :name, :bucket, :last_modified, :etag, :size, :owner, :storage_class

      def initialize(s3, bucket, name, last_modified, etag, size, owner, storage_class)
        @s3 = s3
        @bucket = bucket
        @name = name
        @last_modified = last_modified
        @etag = etag
        @size = size
        @owner = owner
        @storage_class = storage_class
      end

      # Get the headers for this key
      #
      # All header methods map directly to the Net::HTTPHeader module
      def headers
        @headers ||= @s3.key_headers(@bucket, @name)
      end

      # Retrieve the data stored for this Key
      #
      # You can get the data as a single call or add a block to retrieve the data in chunks
      # ==Examples
      #   content = key.data
      #
      # or
      #
      #   key.data do |chunk|
      #     # handle chunk
      #     puts chunk
      #   end
      def data(&block)
        @s3.key_data @bucket, @name, &block
      end

      # Delete this Key
      def delete
        @s3.delete_key(@bucket, @name)
      end

      # Make a copy of this key with a new name
      def copy(new_name, headers = nil, meta_headers = nil)
        @s3.copy_key(@bucket, @name, nil, new_name, headers, meta_headers)
      end

      # Rename or move this key to a new name
      def rename(new_name, headers = nil, meta_headers = nil)
        copied = @s3.copy_key(@bucket, @name, nil, new_name, headers, meta_headers)
        @s3.delete_key(@bucket, @name) if copied
      end
      alias_method :move, :rename

      # Copy this Key to another Bucket
      #
      def copy_to(new_bucket, new_name = nil, headers = nil, meta_headers = nil)
        @s3.copy_key(@bucket, @name, new_bucket, new_name, headers, meta_headers)
      end

      # Move this Key to another Bucket
      def move_to(new_bucket, new_name = nil, headers = nil, meta_headers = nil)
        copied = @s3.copy_key(@bucket, @name, new_bucket, new_name, headers, meta_headers)
        @s3.delete_key(@bucket, @name) if copied
      end
    end

#TODO: Create a more advanced array which can deal with pagination
    class KeyParser < Awsum::Parser #:nodoc:
      def initialize(s3)
        @s3 = s3
        @bucket = ''
        @keys = []
        @text = nil
        @stack = []
      end

      def tag_start(tag, attributes)
        case tag
          when 'ListBucketResult'
            @stack << tag
            @text = ''
          when 'Contents'
            @stack << tag
            @current = {}
            @text = ''
          when 'Owner'
            @owner = {}
            @stack << tag
        end
      end

      def text(text)
        @text << text unless @text.nil?
      end

      def tag_end(tag)
        case tag
          when 'Name'
            if @stack[-1] == 'ListBucketResult'
              @bucket = @text.strip
            end
          when 'Contents'
            @keys << Key.new(
                          @s3,
                          @bucket,
                          @current['Key'],
                          Time.parse(@current['LastModified']),
                          @current['ETag'],
                          @current['Size'].to_i,
                          {'id' => @owner['ID'], 'name' => @owner['DisplayName']},
                          @current['StorageClass']
                        )
            @current = nil
            @text = nil
            @stack.pop
          when 'Owner'
            @stack.pop
          else
            text = @text.strip unless @text.nil?
            case @stack[-1]
              when 'Owner'
                @owner[tag] = (text == '' ? nil : text) unless @owner.nil?
              when 'Contents'
                @current[tag] = (text == '' ? nil : text) unless @current.nil?
            end
            @text = ''
        end
      end

      def result
        @keys
      end
    end
  end
end
