require 'spec_helper'

module Awsum
  describe Ec2 do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }

    describe "retrieving a list of security groups" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeSecurityGroups|, :body => fixture('ec2/security_groups'), :status => 200)
      end

      let(:result) { ec2.security_groups }

      it "should return an array of security groups" do
        result.first.should be_a(Awsum::Ec2::SecurityGroup)
      end
    end

    describe "retrieving a security group by name" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeSecurityGroups.*GroupName.1=default|, :body => fixture('ec2/security_groups'), :status => 200)
      end

      let(:result) { ec2.security_group 'default' }

      it "should return a security group" do
        result.should be_a(Awsum::Ec2::SecurityGroup)
      end
    end

    describe "creating a security group" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=CreateSecurityGroup.*GroupDescription=test%20group.*GroupName=test|, :body => fixture('ec2/create_security_group'), :status => 200)
      end

      it "should return true" do
        ec2.create_security_group('test', 'test group').should be_true
      end
    end

    describe "deleting a security group" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DeleteSecurityGroup.*GroupName=test|, :body => fixture('ec2/delete_security_group'), :status => 200)
      end

      it "should return true" do
        ec2.delete_security_group('test').should be_true
      end
    end

    describe "authorizing group access" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AuthorizeSecurityGroupIngress.*GroupName=test.*SourceSecurityGroupName=default.*SourceSecurityGroupOwnerId=111111111111|, :body => fixture('ec2/delete_security_group'), :status => 200)
      end

      it "should return true" do
        ec2.authorize_security_group_ingress('test', :source_security_group_name => 'default', :source_security_group_owner_id => '111111111111').should be_true
      end
    end

    describe "authorizing ip access" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AuthorizeSecurityGroupIngress.*CidrIp=0.0.0.0%2F0.*FromPort=80.*GroupName=test.*IpProtocol=tcp.*ToPort=80|, :body => fixture('ec2/delete_security_group'), :status => 200)
      end

      it "should return true" do
        ec2.authorize_security_group_ingress('test', :ip_protocol => 'tcp', :from_port => 80, :to_port => 80, :cidr_ip => '0.0.0.0/0').should be_true
      end
    end

    describe "sending ip authorization options to a user/group authorization request" do
      it "should raise an error" do
        expect { ec2.authorize_security_group_ingress('test', :ip_protocol => 'tcp', :from_port => 80, :to_port => 80, :cidr_ip => '0.0.0.0/0', :source_security_group_name => 'default') }.to raise_error
      end
    end

    describe "sending user/group options to a ip authorization request" do
      it "should raise an error" do
        expect { ec2.authorize_security_group_ingress('test', :source_security_group_name => 'default', :source_security_group_owner_id => '111111111111', :from_port => 80, :to_port => 80) }.to raise_error
      end
    end

    describe "sending all options to an authorization request" do
      it "should raise an error" do
        expect { ec2.authorize_security_group_ingress('test', :source_security_group_name => 'default', :source_security_group_owner_id => '111111111111', :ip_protocol => 'tcp', :from_port => 80, :to_port => 80, :cidr_ip => '0.0.0.0/0') }.to raise_error
      end
    end

    describe "including a wrong protocol in an authorization request" do
      it "should raise an error" do
        expect { ec2.authorize_security_group_ingress('test', :ip_protocol => 'test', :from_port => 80, :to_port => 80, :cidr_ip => '0.0.0.0/0') }.to raise_error
      end
    end

    describe "revoking group access" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RevokeSecurityGroupIngress.*GroupName=test.*SourceSecurityGroupName=default.*SourceSecurityGroupOwnerId=111111111111|, :body => fixture('ec2/delete_security_group'), :status => 200)
      end

      it "should return true" do
        ec2.revoke_security_group_ingress('test', :source_security_group_name => 'default', :source_security_group_owner_id => '111111111111').should be_true
      end
    end

    describe "revoking ip access" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RevokeSecurityGroupIngress.*CidrIp=0.0.0.0%2F0.*FromPort=80.*GroupName=test.*IpProtocol=tcp.*ToPort=80|, :body => fixture('ec2/delete_security_group'), :status => 200)
      end

      it "should return true" do
        ec2.revoke_security_group_ingress('test', :ip_protocol => 'tcp', :from_port => 80, :to_port => 80, :cidr_ip => '0.0.0.0/0').should be_true
      end
    end

    describe "sending ip revokation options to a user/group authorization request" do
      it "should raise an error" do
        expect { ec2.revoke_security_group_ingress('test', :ip_protocol => 'tcp', :from_port => 80, :to_port => 80, :cidr_ip => '0.0.0.0/0', :source_security_group_name => 'default') }.to raise_error
      end
    end

    describe "sending user/group options to a ip revokation request" do
      it "should raise an error" do
        expect { ec2.revoke_security_group_ingress('test', :source_security_group_name => 'default', :source_security_group_owner_id => '111111111111', :from_port => 80, :to_port => 80) }.to raise_error
      end
    end

    describe "sending all options to an revokation request" do
      it "should raise an error" do
        expect { ec2.revoke_security_group_ingress('test', :source_security_group_name => 'default', :source_security_group_owner_id => '111111111111', :ip_protocol => 'tcp', :from_port => 80, :to_port => 80, :cidr_ip => '0.0.0.0/0') }.to raise_error
      end
    end

    describe "including a wrong protocol in an revokation request" do
      it "should raise an error" do
        expect { ec2.revoke_security_group_ingress('test', :ip_protocol => 'test', :from_port => 80, :to_port => 80, :cidr_ip => '0.0.0.0/0') }.to raise_error
      end
    end

    describe "a security group" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeSecurityGroups.*GroupName.1=default|, :body => fixture('ec2/security_groups'), :status => 200)
      end

      let(:security_group) { ec2.security_group('default') }

      it "should be able to authorize a group" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AuthorizeSecurityGroupIngress.*GroupName=default.*SourceSecurityGroupName=test.*SourceSecurityGroupOwnerId=111111111111|, :body => fixture('ec2/delete_security_group'), :status => 200)

        security_group.authorize_group('test', '111111111111').should be_true
      end

      it "should be able to authorize ip access" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AuthorizeSecurityGroupIngress.*CidrIp=0.0.0.0%2F0.*FromPort=80.*GroupName=default.*IpProtocol=tcp.*ToPort=80|, :body => fixture('ec2/delete_security_group'), :status => 200)

        security_group.authorize_ip(80, 80, 'tcp', '0.0.0.0/0').should be_true
      end

      it "should be able to revoke a group" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RevokeSecurityGroupIngress.*GroupName=default.*SourceSecurityGroupName=test.*SourceSecurityGroupOwnerId=111111111111|, :body => fixture('ec2/delete_security_group'), :status => 200)

        security_group.revoke_group('test', '111111111111').should be_true
      end

      it "should be able to authorize ip access" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RevokeSecurityGroupIngress.*CidrIp=0.0.0.0%2F0.*FromPort=80.*GroupName=default.*IpProtocol=tcp.*ToPort=80|, :body => fixture('ec2/delete_security_group'), :status => 200)

        security_group.revoke_ip(80, 80, 'tcp', '0.0.0.0/0').should be_true
      end

      it "should be able to delete itself" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DeleteSecurityGroup.*GroupName=default|, :body => fixture('ec2/delete_security_group'), :status => 200)

        security_group.delete.should be_true
      end
    end
  end
end
