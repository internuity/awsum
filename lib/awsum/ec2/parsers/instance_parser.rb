module Awsum
  class Ec2
    class InstanceParser < Awsum::Parser #:nodoc:
      def initialize(ec2)
        @ec2 = ec2
        @instances = []
        @text = nil
        @stack = []
        @placement = nil
        @state = nil
      end

      def tag_start(tag, attributes)
        case tag
          when 'reservationSet', 'instancesSet', 'productCodes', 'instanceState', 'blockDeviceMapping', 'tagSet', 'placement'
            @stack << tag
          when 'item'
            case @stack[-1]
              when 'reservationSet'
              when 'instancesSet'
                @current = {}
                @state = {}
              when 'productCodes'
                @product_codes = []
              when 'blockDeviceMapping'
                @blockDeviceMapping = {}
              when 'tagSet'
                @tagSet = {}
            end
        end
        @text = ''
      end

      def text(text)
        @text << text unless @text.nil?
      end

      def tag_end(tag)
        case tag
          when 'DescribeInstancesResponse', 'requestId', 'reservationId'
            #no-op
          when 'reservationSet', 'instancesSet', 'productCodes', 'instanceState', 'placement', 'blockDeviceMapping', 'tagSet'
            @stack.pop
          when 'item'
            case @stack[-1]
              when 'instancesSet'
                @instances << Instance.new(
                                @ec2,
                                @current['instanceId'],
                                @current['imageId'],
                                @current['instanceType'],
                                State.new(@state[:code], @state[:name]),
                                @current['dnsName'],
                                @current['privateDnsName'],
                                @current['keyName'],
                                @current['kernalId'],
                                Time.parse(@current['launchTime']),
                                @placement,
                                @product_codes || [],
                                @current['ramdisk_id'],
                                @current['reason'],
                                @current['amiLaunchIndex'].to_i
                              )
            end
          when 'productCode'
            @product_codes << @text.strip
          when 'availabilityZone'
            @placement = @text.strip
          when 'code'
            @state[:code] = @text.strip.to_i if @stack[-1] == 'instanceState'
          when 'name'
            @state[:name] = @text.strip if @stack[-1] == 'instanceState'
          else
            case @stack[-1]
              when 'blockDeviceMapping'
                unless @text.nil? || @blockDeviceMapping.nil?
                  text = @text.strip
                  @blockDeviceMapping[tag] = (text == '' ? nil : text)
                end
              when 'tagSet'
                unless @text.nil? || @blockDeviceMapping.nil?
                  text = @text.strip
                  @blockDeviceMapping[tag] = (text == '' ? nil : text)
                end
              else
                unless @text.nil? || @current.nil?
                  text = @text.strip
                  @current[tag] = (text == '' ? nil : text)
                end
            end
        end
      end

      def result
        @instances
      end
    end
  end
end
