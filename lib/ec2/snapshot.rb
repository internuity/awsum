module Awsum
  class Ec2
    class Snapshot
      attr_reader :id, :volume_id, :status, :start_time, :progress

      def initialize(ec2, id, volume_id, status, start_time, progress)
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

    class SnapshotParser < Awsum::Parser
      def initialize(ec2)
        @ec2 = ec2
        @snapshots = []
        @text = nil
        @stack = []
      end

      def tag_start(tag, attributes)
        #Quick hack so we can use the same parser for CreateSnapshot which doesn't use the item tag to wrap the snapshot information
        if tag == 'CreateSnapshotResponse'
          @stack << 'snapshotSet'
        end

        case tag
          when 'snapshotSet'
            @stack << 'snapshotSet'
          when 'item', 'CreateSnapshotResponse'
            case @stack[-1]
              when 'snapshotSet'
                @current = {}
            end
        end
        @text = ''
      end

      def text(text)
        @text << text unless @text.nil?
      end

      def tag_end(tag)
        case tag
          when 'DescribeSnapshotsResponts', 'requestId'
            #no-op
          when 'snapshotSet'
            @stack.pop
          when 'item', 'CreateSnapshotResponse'
            case @stack[-1]
              when 'snapshotSet'
                @snapshots << Snapshot.new(
                                @ec2,
                                @current['snapshotId'], 
                                @current['volumeId'], 
                                @current['status'],
                                @current['startTime'].blank? ? nil :Time.parse(@current['startTime']),
                                @current['progress']
                              )
            end
          else
            unless @text.nil? || @current.nil?
              text = @text.strip
              @current[tag] = (text == '' ? nil : text)
            end
        end
      end

      def result
        @snapshots
      end
    end
  end
end
