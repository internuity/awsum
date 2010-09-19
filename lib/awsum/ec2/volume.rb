require 'awsum/ec2/parsers/volume_parser'

module Awsum
  class Ec2
    class Volume
      attr_reader :id, :instance_id, :size, :status, :create_time, :snapshot_id, :device, :attach_time, :availability_zone, :attachment_status

      def initialize(ec2, id, instance_id, size, status, create_time, snapshot_id, device, attach_time, availability_zone, attachment_status) #:nodoc:
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

      # Will reload the information about this Volume
      #
      # Useful for when a volume has just been created but is not yet available
      #   while volume.status != 'available'
      #     volume.reload
      #   end
      def reload
        reloaded_volume = @ec2.volume id

        @id = id
        @instance_id = reloaded_volume.instance_id
        @size = reloaded_volume.size
        @status = reloaded_volume.status
        @create_time = reloaded_volume.create_time
        @snapshot_id = reloaded_volume.snapshot_id
        @device = reloaded_volume.device
        @attach_time = reloaded_volume.attach_time
        @availability_zone = reloaded_volume.availability_zone
        @attachment_status = reloaded_volume.attachment_status
      end

      # Detach this volume
      def detach(force = false)
        @ec2.detach_volume id, :force => force
      end

      # Delete this volume
      def delete
        @ec2.delete_volume id
      end

      # Creates a Snapshot of this Volume
      def create_snapshot
        @ec2.create_snapshot id
      end

      # Lists the Snapshot(s) of this Volume
      def snapshots
        snapshots = @ec2.snapshots
        snapshots.delete_if {|s| s.volume_id != id}
      end
    end
  end
end
