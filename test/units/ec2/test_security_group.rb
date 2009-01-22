require File.expand_path('../../helper', File.dirname(__FILE__))

class SecurityGroupsTest < Test::Unit::TestCase
  context "SecurityGroupParser:" do
    context "Parsing the result of a call to DescribeSecurityGroups" do
      setup {
        ec2 = Awsum::Ec2.new('abc', 'xyz')
        xml = load_fixture('ec2/security_groups')
        parser = Awsum::Ec2::SecurityGroupParser.new(ec2)
        @result = parser.parse(xml)
      }

      should "return an array of security_groups" do
        assert @result.is_a?(Array)
        assert @result[0].is_a?(Awsum::Ec2::SecurityGroup)
      end

      context ", the first security_group" do
        setup {
          @security_group = @result[0]
        }

        should "have the correct name" do
          assert_equal "default", @security_group.name
        end

        should "have the correct description" do
          assert_equal "default group", @security_group.description
        end

        should "have the correct owner id" do
          assert_equal "111111111111", @security_group.owner_id
        end

        should "have 3 group permissions" do
          assert_equal 3, @security_group.group_permissions.size
        end

        should "have SecurityGroup::GroupPermission in the group_permissions array" do
          @security_group.group_permissions.each do |p|
            assert_equal Awsum::Ec2::SecurityGroup::GroupPermission, p.class
          end
        end

        should "have 4 ip permissions" do
          assert_equal 4, @security_group.ip_permissions.size
        end

        should "have SecurityGroup::IpPermission in the ip_permissions array" do
          @security_group.ip_permissions.each do |p|
            assert_equal Awsum::Ec2::SecurityGroup::IpPermission, p.class
          end
        end

        context ", in the first group permission" do
          setup {
            @group_permission = @security_group.group_permissions[0]
          }

          should "have protocol of tcp" do
            assert_equal 'tcp', @group_permission.protocol
          end

          should "have from port of 0" do
            assert_equal 0, @group_permission.from_port
          end

          should "have to port of 65535" do
            assert_equal 65535, @group_permission.to_port
          end

          should "have group of default" do
            assert_equal 'default', @group_permission.group
          end

          should "have owner id of 111111111111" do
            assert_equal '111111111111', @group_permission.user_id
          end
        end

        context ", in the first ip permission" do
          setup {
            @ip_permission = @security_group.ip_permissions[0]
          }

          should "have protocol of tcp" do
            assert_equal 'tcp', @ip_permission.protocol
          end

          should "have from port of 22" do
            assert_equal 22, @ip_permission.from_port
          end

          should "have to port of 22" do
            assert_equal 22, @ip_permission.to_port
          end

          should "have ip of 0.0.0.0/0" do
            assert_equal '0.0.0.0/0', @ip_permission.ip
          end
        end
      end
    end
  end
end
