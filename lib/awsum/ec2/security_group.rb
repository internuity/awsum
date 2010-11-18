require 'awsum/ec2/parsers/security_group_parser'

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

      # Authorize access
      #
      # ===Options:
      # See Ec2#authorize_security_group_ingress
      def authorize(arguments)
        @ec2.authorize_security_group_ingress(@name, arguments)
      end

      # Revoke access
      #
      # ===Options:
      # See Ec2#revoke_security_group_ingress
      def revoke(arguments)
        @ec2.revoke_security_group_ingress(@name, arguments)
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
  end
end
