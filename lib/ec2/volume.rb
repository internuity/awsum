module Awsum
  class Ec2
    class Volume
      attr_reader :id, :instance_id, :size, :status, :create_time, :snapshot_id, :device, :attach_time, :availability_zone, :attachment_status

      def initialize(ec2, id, instance_id, size, status, create_time, snapshot_id, device, attach_time, availability_zone, attachment_status)
        @ec2 = ec2
        @id = id
        @instance_id = instance_id
        @size = size
        @status = status
        @create_time = create_time
        @snapshot_id = snapshot_id
        @device = device
        @attach_time = attach_time
        @availability_zone = availability_zone
        @attachment_status = attachment_status
      end
    end

    class VolumeParser < Awsum::Parser
      def initialize(ec2)
        @ec2 = ec2
        @volumes = []
        @text = nil
        @stack = []
      end

      def tag_start(tag, attributes)
        #Quick hack so we can use the same parser for CreateVolume which doesn't use the item tag to wrap the volume information
        if tag == 'CreateVolumeResponse'
          @stack << 'volumeSet'
        end

        case tag
          when 'volumeSet'
            @stack << 'volumeSet'
          when 'attachmentSet'
            @stack << 'attachmentSet'
          when 'item', 'CreateVolumeResponse'
            case @stack[-1]
              when 'volumeSet'
                @current = {}
              when 'attachmentSet'
            end
        end
        @text = ''
      end

      def text(text)
        @text << text unless @text.nil?
      end

      def tag_end(tag)
        case tag
          when 'DescribeVolumesResponse', 'requestId'
            #no-op
          when 'volumeSet', 'attachmentSet'
            @stack.pop
          when 'item', 'CreateVolumeResponse'
            case @stack[-1]
              when 'volumeSet'
                @volumes << Volume.new(
                                @ec2,
                                @current['volumeId'], 
                                @current['instanceId'], 
                                @current['size'].to_i, 
                                @current['status'],
                                @current['createTime'].blank? ? nil :Time.parse(@current['createTime']),
                                @current['snapshotId'], 
                                @current['device'],
                                @current['attachTime'].blank? ? nil :Time.parse(@current['attachTime']),
                                @current['availabilityZone'],
                                @current['attachment_status']
                              )
            end
          else
            unless @text.nil? || @current.nil?
              text = @text.strip
              #Handle special case for attachmentSet/status
              if @stack[-1] == 'attachmentSet' && tag == 'status'
                @current['attachment_status'] = (text == '' ? nil : text)
              else
                @current[tag] = (text == '' ? nil : text)
              end
            end
        end
      end

      def result
        @volumes
      end
    end
  end
end
