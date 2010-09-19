require 'spec_helper'

module Awsum
  describe Ec2::SecurityGroupParser do
    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::SecurityGroupParser.new(ec2) }

    describe "parsing the result of a call to DescribeSecurityGroups" do
      let(:result) { parser.parse(fixture('ec2/security_groups')) }

      it "should return an array of security groups" do
        result.should be_a(Array)
      end

      context "the first security group" do
        let(:security_group) { result.first }

        {
          :name         => 'default',
          :description  => 'default group',
          :owner_id     => '111111111111'
        }.each do |key, value|
          it "should have the correct #{key}" do
            security_group.send(key).should == value
          end
        end

        it "should have 3 group permissions" do
          security_group.should have(3).group_permissions
        end

        it "should have SecurityGroup::GroupPermission in the group_permissions array" do
          security_group.group_permissions.first.should be_a(Awsum::Ec2::SecurityGroup::GroupPermission)
        end

        it "should have 4 ip permissions" do
          security_group.should have(4).ip_permissions
        end

        it "should have SecurityGroup::IpPermission in the ip_permissions array" do
          security_group.ip_permissions.first.should be_a(Awsum::Ec2::SecurityGroup::IpPermission)
        end

        context "in the first group permission" do
          let(:group_permission) { security_group.group_permissions.first }

          {
            :protocol   => 'tcp',
            :from_port  => 0,
            :to_port    => 65535,
            :group      => 'default',
            :user_id    => '111111111111'
          }.each do |key, value|
            it "should have the correct #{key}" do
              group_permission.send(key).should == value
            end
          end
        end

        context "in the first ip permission" do
          let(:ip_permission) { security_group.ip_permissions.first }

          {
            :protocol   => 'tcp',
            :from_port  => 22,
            :to_port    => 22,
            :ip         => '0.0.0.0/0'
          }.each do |key, value|
            it "should have the correct #{key}" do
              ip_permission.send(key).should == value
            end
          end
        end
      end
    end
  end
end
