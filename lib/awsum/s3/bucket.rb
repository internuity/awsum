require 'awsum/s3/parsers/bucket_parser'

module Awsum
  class S3
    class Bucket
      attr_reader :name, :creation_date

      def initialize(s3, name, creation_date = nil)
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
  end
end
