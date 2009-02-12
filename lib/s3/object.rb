module Awsum
  class S3
    class Object
      attr_reader :key, :bucket, :last_modified, :etag, :size, :owner, :storage_class

      def initialize(s3, bucket, key, last_modified, etag, size, owner, storage_class)
        @s3 = s3
        @bucket = bucket
        @key = key
        @last_modified = last_modified
        @etag = etag
        @size = size
        @owner = owner
        @storage_class = storage_class
      end

      # Get the headers for this Object
      #
      # All header methods map directly to the Net::HTTPHeader module
      def headers
        @headers ||= @s3.object_headers(@bucket, @key)
      end

      # Retrieve the data stored for this Object
      #
      # You can get the data as a single call or add a block to retrieve the data in chunks
      # ==Examples
      #   content = object.data
      #
      # or
      #
      #   object.data do |chunk|
      #     # handle chunk
      #     puts chunk
      #   end
      def data(&block)
        @s3.object_data @bucket, @key, &block
      end

      # Delete this Key
      def delete
        @s3.delete_object(@bucket, @key)
      end

      # Make a copy of this Object with a new key
      def copy(new_key, headers = nil, meta_headers = nil)
        @s3.copy_object(@bucket, @key, nil, new_key, headers, meta_headers)
      end

      # Rename or move this Object to a new key
      def rename(new_key, headers = nil, meta_headers = nil)
        copied = @s3.copy_object(@bucket, @key, nil, new_key, headers, meta_headers)
        @s3.delete_object(@bucket, @key) if copied
      end
      alias_method :move, :rename

      # Copy this Object to another Bucket
      #
      def copy_to(new_bucket, new_key = nil, headers = nil, meta_headers = nil)
        @s3.copy_object(@bucket, @key, new_bucket, new_key, headers, meta_headers)
      end

      # Move this Object to another Bucket
      def move_to(new_bucket, new_key = nil, headers = nil, meta_headers = nil)
        copied = @s3.copy_object(@bucket, @key, new_bucket, new_key, headers, meta_headers)
        @s3.delete_object(@bucket, @key) if copied
      end
    end

#TODO: Create a more advanced array which can deal with pagination
    class ObjectParser < Awsum::Parser #:nodoc:
      def initialize(s3)
        @s3 = s3
        @bucket = ''
        @objects = []
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
            @objects << Object.new(
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
        @objects
      end
    end
  end
end
