module Awsum
  class Ec2 < Awsum::Requestable
    class Image
      attr_reader :id, :location, :state, :owner, :public, :architecture, :type, :kernel_id, :ram_disk_id

      def initialize(id, location, state, owner, public, architecture, type, kernel_id, ram_disk_id)
        @id = id 
        @location = location 
        @state = state 
        @owner = owner 
        @public = public 
        @architecture = architecture 
        @type = type 
        @kernel_id = kernel_id 
        @ram_disk_id = ram_disk_id
      end
    end

    class ImageParser < Awsum::Parser
      def initialize
        @images = []
        @text = nil
      end

      def tag_start(tag, attributes)
        case tag
          when 'item'
            @current = {}
            @text = ''
          else
            #no-op
        end
      end

      def text(text)
        @text << text unless @text.nil?
      end

      def tag_end(tag)
        case tag
          when 'DescribeImagesResponse', 'imageSet'
            #no-op
          when 'item'
            @images << Image.new(
                          @current['imageId'], 
                          @current['imageLocation'], 
                          @current['imageState'], 
                          @current['OwnerId'], 
                          @current['isPublic'], 
                          @current['architecture'], 
                          @current['imageType'],
                          @current['kernelId'],
                          @current['ramdiskId']
                        )
            @text = ''
          else
            unless @text.nil?
              @current[tag] = @text.strip
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
