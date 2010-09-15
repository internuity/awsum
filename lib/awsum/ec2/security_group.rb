module Awsum
  class Ec2
    class SecurityGroup
      attr_reader :name, :description, :owner_id, :ip_permissions, :group_permissions

      def initialize(ec2, name, description, owner_id, ip_permissions, group_permissions)
        @ec2 = ec2
        @name = name
        @description = description
        @owner_id = owner_id
        @ip_permissions = ip_permissions
        @group_permissions = group_permissions
      end

      # Authorize access for a group
      def authorize_group(group_name, owner_id)
        @ec2.authorize_security_group_ingress(@name, :source_security_group_name => group_name, :source_security_group_owner_id => owner_id)
      end

      # Revoke access for a group
      def revoke_group(group_name, owner_id)
        @ec2.revoke_security_group_ingress(@name, :source_security_group_name => group_name, :source_security_group_owner_id => owner_id)
      end

      # Authorize access for an ip address
      def authorize_ip(from_port, to_port, protocol = 'tcp', cidr_ip = '0.0.0.0/0')
        @ec2.authorize_security_group_ingress(@name, :ip_protocol => protocol, :from_port => from_port, :to_port => to_port, :cidr_ip => cidr_ip)
      end

      # Revoke access from an ip address
      def revoke_ip(from_port, to_port, protocol = 'tcp', cidr_ip = '0.0.0.0/0')
        @ec2.revoke_security_group_ingress(@name, :ip_protocol => protocol, :from_port => from_port, :to_port => to_port, :cidr_ip => cidr_ip)
      end

      # Delete this SecurityGroup
      def delete
        @ec2.delete_security_group(@name)
      end

    private
      class Permission #:nodoc:
        attr_reader :protocol, :from_port, :to_port

        def initialize(protocol, from_port, to_port)
          @protocol = protocol
          @from_port = from_port.to_i
          @to_port = to_port.to_i
        end
      end

    protected
      class IpPermission < Permission
        attr_reader :ip

        def initialize(protocol, from_port, to_port, ip)
          super(protocol, from_port, to_port)
          @ip = ip
        end
      end

      class GroupPermission < Permission
        attr_reader :group, :user_id

        def initialize(protocol, from_port, to_port, group, user_id)
          super(protocol, from_port, to_port)
          @group = group
          @user_id = user_id
        end
      end
    end

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
