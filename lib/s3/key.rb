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

      # Delete this Key
      def delete
        @s3.delete_key(@bucket, @name)
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
