require 'awsum/ec2/parsers/instance_parser.rb'

module Awsum
  class Ec2
    class Instance
      attr_reader :id, :image_id, :type, :state, :dns_name, :private_dns_name, :key_name, :kernel_id, :launch_time, :availability_zone, :product_codes, :ramdisk_id, :reason, :launch_index

      def initialize(ec2, id, image_id, type, state, dns_name, private_dns_name, key_name, kernel_id, launch_time, availability_zone, product_codes, ramdisk_id, reason, launch_index) #:nodoc:
        @ec2 = ec2
        @id = id
        @image_id = image_id
        @type = type
        @state = state
        @dns_name = dns_name
        @private_dns_name = private_dns_name
        @key_name = key_name
        @kernel_id = kernel_id
        @launch_time = launch_time
        @availability_zone = availability_zone
        @product_codes = product_codes
        @ramdisk_id = ramdisk_id
        @reason = reason
        @launch_index = launch_index
      end

      # Terminates this instance
      def terminate
        @ec2.terminate_instances(id)
      end

      # Lists all the Volume(s) attached to this Instance
      def volumes
        volumes = @ec2.volumes
        volumes.delete_if {|v| v.instance_id != id}
      end

      # Will create and attach a Volume to this Instance
      # You must specify a size or a snapshot_id
      def create_volume(size = nil, snapshot_id = nil, device = '/dev/sdh')
        raise ArgumentError.new('You must specify a size if not creating a volume from a snapshot') if size.blank? && snapshot_id.blank?
        raise ArgumentError.new('You must specify a device to attach the volume to') unless device

        volume = @ec2.create_volume availability_zone, :size => size, :snapshot_id => snapshot_id
        while volume.status != 'available'
          volume.reload
        end
        attach volume, device
        volume
      end

      # Will attach a Volume to this Instance
      def attach(volume, device = '/dev/sdh')
        @ec2.attach_volume volume.id, id, device
      end
    end
  end
end
