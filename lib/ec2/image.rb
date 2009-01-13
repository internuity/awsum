module Awsum
  class Ec2
    class Image
      attr_reader :id, :location, :state, :owner, :public, :architecture, :type, :kernel_id, :ramdisk_id, :platform, :product_codes

      def initialize(id, location, state, owner, public, architecture, type, kernel_id, ram_disk_id, platform, product_codes)
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
    end

    class ImageParser < Awsum::Parser
      def initialize
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
