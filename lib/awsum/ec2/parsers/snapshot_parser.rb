module Awsum
  class Ec2
    class SnapshotParser < Awsum::Parser #:nodoc:
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
          when 'snapshotSet', 'tagSet'
            @stack << tag
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
          when 'DescribeSnapshotsResponts'
            #no-op
          when 'snapshotSet', 'tagSet'
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
