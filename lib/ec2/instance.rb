require 'time'

module Awsum
  class Ec2
    class Instance
      attr_reader :id, :image_id, :type, :state, :dns_name, :private_dns_name, :key_name, :kernel_id, :launch_time, :placement, :product_codes, :ramdisk_id, :reason, :launch_index

      def initialize(id, image_id, type, state, dns_name, private_dns_name, key_name, kernel_id, launch_time, placement, product_codes, ramdisk_id, reason, launch_index)
        @id = id
        @image_id = image_id
        @type = type
        @state = state
        @dns_name = dns_name
        @private_dns_name = private_dns_name
        @key_name = key_name
        @kernel_id = kernel_id
        @launch_time = launch_time
        @placement = placement
        @product_codes = product_codes
        @ramdisk_id = ramdisk_id
        @reason = reason
        @launch_index = launch_index
      end
    end

    class InstanceParser < Awsum::Parser
      def initialize
        @instances = []
        @text = nil
        @stack = []
        @placement = nil
        @state = {}
      end

      def tag_start(tag, attributes)
        case tag
          when 'reservationSet'
            @stack << 'reservationSet'
          when 'instancesSet'
            @stack << 'instancesSet'
          when 'productCodes'
            @stack << 'productCodes'
          when 'instanceState'
            @stack << 'instanceState'
          when 'placement'
            @stack << 'placement'
          when 'item'
            case @stack[-1]
              when 'reservationSet'
              when 'instancesSet'
                @current = {}
              when 'productCodes'
                @product_codes = []
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
          when 'reservationSet', 'instancesSet', 'productCodes', 'instanceState', 'placement'
            @stack.pop
          when 'item'
            case @stack[-1]
              when 'instancesSet'
                @instances << Instance.new(
                                @current['instanceId'], 
                                @current['imageId'], 
                                @current['instanceType'], 
                                @state,
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
            unless @text.nil? || @current.nil?
              text = @text.strip
              @current[tag] = (text == '' ? nil : text)
            end
        end
      end

      def result
        @instances
      end
    end
  end
end
