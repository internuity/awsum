module Awsum
  class S3
    class Bucket
      attr_reader :name, :creation_date

      def initialize(s3, name, creation_date)
        @s3 = s3
        @name = name
        @creation_date = creation_date
      end

      # Delete this Bucket
      def delete
        @s3.delete_bucket(@name)
      end

      # Delete this Bucket, recursively deleting all keys first
      def delete!
        @s3.keys(@name).each do |key|
          key.delete
        end
        delete
      end
    end

    class BucketParser < Awsum::Parser #:nodoc:
      def initialize(s3)
        @s3 = s3
        @buckets = []
        @text = nil
      end

      def tag_start(tag, attributes)
        case tag
          when 'Bucket'
            @current = {}
            @text = ''
        end
      end

      def text(text)
        @text << text unless @text.nil?
      end

      def tag_end(tag)
        case tag
          when 'Bucket'
            @buckets << Bucket.new(
                          @s3,
                          @current['Name'],
                          Time.parse(@current['CreationDate'])
                        )
            @text = nil
            @current = nil
          else
            text = @text.strip unless @text.nil?
            @current[tag] = (text == '' ? nil : text) unless @current.nil?
        end
      end

      def result
        @buckets
      end
    end
  end
end
