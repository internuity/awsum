require 'awsum/ec2/parsers/snapshot_parser'

module Awsum
  class Ec2
    class Snapshot
      attr_reader :id, :volume_id, :status, :start_time, :progress

      def initialize(ec2, id, volume_id, status, start_time, progress) #:nodoc:
        @ec2 = ec2
        @id = id
        @volume_id = volume_id
        @status = status
        @start_time = start_time
        @progress = progress
      end

      # Delete this Snapshot
      def delete
        @ec2.delete_snapshot id
      end
    end
  end
end
