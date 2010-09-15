module Awsum
  class Ec2
    class Region
      attr_reader :name, :end_point

      def initialize(ec2, name, end_point) #:nodoc:
        @ec2 = ec2
        @name = name
        @end_point = end_point
      end

      # List the AvailabilityZone(s) of this Region
      def availability_zones
        @ec2.availability_zones
      end

      # Operate all Awsum::Ec2 methods against this Region
      #
      # ====Example
      #
      #   ec2.region('eu-west-1').use do
      #     #Runs an instance within the eu-west-1 region
      #     instance = run_instances('i-ABCDEF')
      #   end
      def use(&block)
        old_host = @ec2.host
        @ec2.host = end_point
        if block_given?
          block.arity < 1 ? instance_eval(&block) : block[self]
        end
        @ec2.host = old_host
        self
      end

    private
      #--
      # Will pass all missing methods onto the ec2 object
      def method_missing(method_name, *args, &block)
        @ec2.send(method_name, *args, &block)
      end
    end

    class RegionParser < Awsum::Parser #:nodoc:
      def initialize(ec2)
        @ec2 = ec2
        @regions = []
        @text = nil
        @stack = []
      end

      def tag_start(tag, attributes)
        case tag
          when 'regionInfo'
            @stack << 'regionInfo'
          when 'item'
            case @stack[-1]
              when 'regionInfo'
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
          when 'DescribeRegionsResponse', 'requestId'
            #no-op
          when 'regionInfo'
            @stack.pop
          when 'item'
            case @stack[-1]
              when 'regionInfo'
                @regions << Region.new(
                                @ec2,
                                @current['regionName'], 
                                @current['regionEndpoint']
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
        @regions
      end
    end
  end
end
