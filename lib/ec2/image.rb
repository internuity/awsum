module Awsum
  class Ec2
    class Image
      attr_reader :id, :location, :state, :owner, :public, :architecture, :type, :kernel_id, :ramdisk_id, :platform, :product_codes

      def initialize(ec2, id, location, state, owner, public, architecture, type, kernel_id, ram_disk_id, platform, product_codes)
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

      # launches instances of this image
      #
      # Options:
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

    class ImageParser < Awsum::Parser
      def initialize(ec2)
        @ec2 = ec2
        @images = []
        @text = nil
        @stack = []
      end

      def tag_start(tag, attributes)
        case tag
          when 'imagesSet'
            @stack << 'imagesSet'
          when 'item'
            case @stack[-1]
              when 'imagesSet'
                @current = {}
                @text = ''
              when 'productCodes'
                @product_codes = []
                @text = ''
            end
          when 'productCodes'
            @stack << 'productCodes'
        end
      end

      def text(text)
        @text << text unless @text.nil?
      end

      def tag_end(tag)
        case tag
          when 'DescribeImagesResponse', 'requestId'
            #no-op
          when 'imagesSet', 'productCodes'
            @stack.pop
          when 'item'
            case @stack[-1]
              when 'imagesSet'
                @images << Image.new(
                              @ec2,
                              @current['imageId'], 
                              @current['imageLocation'], 
                              @current['imageState'], 
                              @current['imageOwnerId'], 
                              @current['isPublic'] == 'true', 
                              @current['architecture'], 
                              @current['imageType'],
                              @current['kernelId'],
                              @current['ramdiskId'],
                              @current['platform'],
                              @product_codes || []
                            )
                @text = ''
            end
          when 'productCode'
            @product_codes << @text.strip
          else
            unless @text.nil?
              text = @text.strip
              @current[tag] = (text == '' ? nil : text)
              @text = ''
            end
        end
      end

      def result
        @images
      end
    end
  end
end
