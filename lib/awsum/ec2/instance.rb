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

      def reload
        replacement_instance = @ec2.instance id
        #TODO: Make this easier
        @image_id = replacement_instance.image_id
        @type = replacement_instance.type
        @state = replacement_instance.state
        @dns_name = replacement_instance.dns_name
        @private_dns_name = replacement_instance.private_dns_name
        @key_name = replacement_instance.key_name
        @kernel_id = replacement_instance.kernel_id
        @launch_time = replacement_instance.launch_time
        @availability_zone = replacement_instance.availability_zone
        @product_codes = replacement_instance.product_codes
        @ramdisk_id = replacement_instance.ramdisk_id
        @reason = replacement_instance.reason
        @launch_index = replacement_instance.launch_index
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
      #
      # ===Options:
      # :tags => Hash of tags
      # :device => Will automatically attach the volume to the specified device
      def create_volume(size_or_snapshot_id, options = {})
        options = {:device => '/dev/sdh'}.merge(options)
        if size_or_snapshot_id.is_a?(Numeric)
          volume = @ec2.create_volume availability_zone, :size => size_or_snapshot_id
        else
          volume = @ec2.create_volume availability_zone, :snapshot_id => size_or_snapshot_id
        end
        if options[:tags]
          @ec2.create_tags(volume.id, options[:tags])
        end
        while volume.status != 'available'
          volume.reload
        end
        if options[:device]
          attach volume, options[:device]
        end
        volume
      end

      # Will attach a Volume to this Instance
      def attach(volume, device = '/dev/sdh')
        @ec2.attach_volume volume.id, id, device
      end
    end
  end
end
