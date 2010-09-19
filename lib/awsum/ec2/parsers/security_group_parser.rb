module Awsum
  class Ec2
    class SecurityGroupParser < Awsum::Parser #:nodoc:
      def initialize(ec2)
        @ec2 = ec2
        @security_groups = []
        @text = nil
        @stack = []
        @group_permissions = []
        @ip_permissions = []
      end

      def tag_start(tag, attributes)
        case tag
          when 'securityGroupInfo'
            @stack << 'securityGroupInfo'
          when 'ipPermissions'
            @stack << 'ipPermissions'
          when 'groups'
            @stack << 'groups'
          when 'ipRanges'
            @stack << 'ipRanges'
          when 'item'
            case @stack[-1]
              when 'securityGroupInfo'
                @current = {}
                @group_permissions = []
                @ip_permissions = []
                @text = ''
              when 'ipPermissions'
                @permissions = {}
                @text = ''
              when 'groups'
                @group_info = {}
                @text = ''
              when 'ipRanges'
                @ip_info = {}
                @text = ''
            end
        end
      end

      def text(text)
        @text << text unless @text.nil?
      end

      def tag_end(tag)
        case tag
          when 'DescribeSecurityGroupsResponse', 'requestId'
            #no-op
          when 'securityGroupInfo', 'ipPermissions', 'groups', 'ipRanges'
            @stack.pop
          when 'item'
            case @stack[-1]
              when 'securityGroupInfo'
                @security_groups << SecurityGroup.new(
                              @ec2,
                              @current['groupName'],
                              @current['groupDescription'],
                              @current['ownerId'],
                              @ip_permissions,
                              @group_permissions
                            )
                @text = ''
              when 'groups'
                @group_permissions << SecurityGroup::GroupPermission.new(
                              @permissions['ipProtocol'],
                              @permissions['fromPort'],
                              @permissions['toPort'],
                              @group_info['groupName'],
                              @group_info['userId']
                            )
              when 'ipRanges'
                @ip_permissions << SecurityGroup::IpPermission.new(
                              @permissions['ipProtocol'],
                              @permissions['fromPort'],
                              @permissions['toPort'],
                              @ip_info['cidrIp']
                            )
            end
          else
            unless @text.nil?
              text = @text.strip
              text = (text == '' ? nil : text)

              case @stack[-1]
                when 'securityGroupInfo'
                  @current[tag] = text
                when 'ipPermissions'
                  @permissions[tag] = text
                when 'groups'
                  @group_info[tag] = text
                when 'ipRanges'
                  @ip_info[tag] = text
              end
              @text = ''
            end
        end
      end

      def result
        @security_groups
      end
    end
  end
end
