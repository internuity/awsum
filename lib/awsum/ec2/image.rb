require 'awsum/ec2/parsers/image_parser.rb'
require 'awsum/ec2/parsers/register_image_parser.rb'

module Awsum
  class Ec2
    class Image
      attr_reader :id, :location, :state, :owner, :public, :architecture, :type, :kernel_id, :ramdisk_id, :platform, :product_codes

      def initialize(ec2, id, location, state, owner, public, architecture, type, kernel_id, ram_disk_id, platform, product_codes) #:nodoc:
        @ec2 = ec2
        @id = id
        @location = location
        @state = state
        @owner = owner
        @public = public
        @architecture = architecture
        @type = type
        @kernel_id = kernel_id
        @ramdisk_id = ram_disk_id
        @platform = platform
        @product_codes = product_codes
      end

      def public?
        @public
      end

      # Deregister this Image
      def deregister
        @ec2.deregister_image @id
      end

      # Reregister this image
      #
      # Will both deregister and then register the Image again
      def reregister
        @ec2.deregister_image @id
        new_id = @ec2.register_image @location
        @id = new_id
        self
      end

      # launches instances of this image
      #
      # ===Options:
      # * <tt>:min</tt> - The minimum number of instances to launch. Default: 1
      # * <tt>:max</tt> - The maximum number of instances to launch. Default: 1
      # * <tt>:key_name</tt> - The name of the key pair with which to launch instances
      # * <tt>:security_groups</tt> - The names of security groups to associate launched instances with
      # * <tt>:user_data</tt> - User data made available to instances (Note: Must be 16K or less, will be base64 encoded by Awsum)
      # * <tt>:instance_type</tt> - The size of the instances to launch, can be one of [m1.small, m1.large, m1.xlarge, c1.medium, c1.xlarge], default is m1.small
      # * <tt>:availability_zone</tt> - The name of the availability zone to launch this instance in
      # * <tt>:kernel_id</tt> - The ID of the kernel with which to launch instances
      # * <tt>:ramdisk_id</tt> - The ID of the RAM disk with which to launch instances
      # * <tt>:block_device_map</tt> - A 'hash' of mappings. E.g. {'instancestore0' => 'sdb'}
      def run(options = {})
        @ec2.run_instances(id, options)
      end
      alias_method :launch, :run
    end
  end
end
