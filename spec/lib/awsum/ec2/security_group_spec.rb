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
      context "with a single option hash" do
        before do
          FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AuthorizeSecurityGroupIngress.*GroupName=test.*IpPermissions.1.FromPort=80.*IpPermissions.1.Groups.1.GroupName=webservers.*IpPermissions.1.IpProtocol=tcp.*IpPermissions.1.ToPort=80|, :body => fixture('ec2/authorize_group_access'), :status => 200)
        end

        it "should return true" do
          ec2.authorize_security_group_ingress('test', {:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :groups => [{:group_name => :webservers}]}).should be_true
        end
      end

      context "with an array of option hashes" do
        before do
          FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AuthorizeSecurityGroupIngress.*GroupName=test.*IpPermissions.1.FromPort=80.*IpPermissions.1.Groups.1.GroupName=webservers.*IpPermissions.1.IpProtocol=tcp.*IpPermissions.1.ToPort=80.*IpPermissions.2.FromPort=22.*IpPermissions.2.Groups.1.GroupName=webservers.*IpPermissions.2.Groups.2.GroupName=dbservers.*IpPermissions.2.IpProtocol=tcp.*IpPermissions.2.ToPort=22|, :body => fixture('ec2/authorize_group_access'), :status => 200)
        end

        it "should return true" do
          ec2.authorize_security_group_ingress('test', [
            {:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :groups => [{:group_name => :webservers}]},
            {:ip_protocol => :tcp, :from_port => 22, :to_port => 22, :groups => [{:group_name => :webservers}, {:group_name => :dbservers}]}
          ]).should be_true
        end
      end
    end

    describe "authorizing ip access" do
      context "with a single option hash" do
        before do
          FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AuthorizeSecurityGroupIngress.*GroupName=test.*IpPermissions.1.FromPort=80.*IpPermissions.1.IpProtocol=tcp.*IpPermissions.1.IpRanges.1.CidrIp=12.23.34.45%2F0.*IpPermissions.1.ToPort=80|, :body => fixture('ec2/authorize_group_access'), :status => 200)
        end

        it "should return true" do
          ec2.authorize_security_group_ingress('test', [{:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}]}])
        end
      end

      context "with an array of option hashes" do
        before do
          FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AuthorizeSecurityGroupIngress.*GroupName=test.*IpPermissions.1.FromPort=80.*IpPermissions.1.IpProtocol=tcp.*IpPermissions.1.IpRanges.1.CidrIp=12.23.34.45%2F0.*IpPermissions.1.ToPort=80.*IpPermissions.2.FromPort=22.*IpPermissions.2.IpProtocol=tcp.*IpPermissions.2.IpRanges.1.CidrIp=12.23.34.45%2F0.*IpPermissions.2.IpRanges.2.CidrIp=12.34.56.78%2F0.*IpPermissions.2.ToPort=22|, :body => fixture('ec2/authorize_group_access'), :status => 200)
        end

        it "should return true" do
          ec2.authorize_security_group_ingress('test', [
            {:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}]},
            {:ip_protocol => :tcp, :from_port => 22, :to_port => 22, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}, {:cidr_ip => '12.34.56.78/0'}]}
          ])
        end
      end
    end

    describe "authorizing both group and ip access" do
      context "with a single call" do
        before do
          FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AuthorizeSecurityGroupIngress.*GroupName=test.*IpPermissions.1.FromPort=80.*IpPermissions.1.IpProtocol=tcp.*IpPermissions.1.IpRanges.1.CidrIp=12.23.34.45%2F0.*IpPermissions.1.ToPort=80.*IpPermissions.2.FromPort=22.*IpPermissions.2.Groups.1.GroupName=webservers.*IpPermissions.2.IpProtocol=tcp.*IpPermissions.2.ToPort=22|, :body => fixture('ec2/authorize_group_access'), :status => 200)
        end

        it "should return true" do
          ec2.authorize_security_group_ingress('test', [
            {:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}]},
            {:ip_protocol => :tcp, :from_port => 22, :to_port => 22, :groups => [{:group_name => 'webservers'}]}
          ])
        end
      end
    end

    describe "revoking group access" do
      context "with a single option hash" do
        before do
          FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RevokeSecurityGroupIngress.*GroupName=test.*IpPermissions.1.FromPort=80.*IpPermissions.1.Groups.1.GroupName=webservers.*IpPermissions.1.IpProtocol=tcp.*IpPermissions.1.ToPort=80|, :body => fixture('ec2/authorize_group_access'), :status => 200)
        end

        it "should return true" do
          ec2.revoke_security_group_ingress('test', {:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :groups => [{:group_name => :webservers}]}).should be_true
        end
      end

      context "with an array of option hashes" do
        before do
          FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RevokeSecurityGroupIngress.*GroupName=test.*IpPermissions.1.FromPort=80.*IpPermissions.1.Groups.1.GroupName=webservers.*IpPermissions.1.IpProtocol=tcp.*IpPermissions.1.ToPort=80.*IpPermissions.2.FromPort=22.*IpPermissions.2.Groups.1.GroupName=webservers.*IpPermissions.2.Groups.2.GroupName=dbservers.*IpPermissions.2.IpProtocol=tcp.*IpPermissions.2.ToPort=22|, :body => fixture('ec2/authorize_group_access'), :status => 200)
        end

        it "should return true" do
          ec2.revoke_security_group_ingress('test', [
            {:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :groups => [{:group_name => :webservers}]},
            {:ip_protocol => :tcp, :from_port => 22, :to_port => 22, :groups => [{:group_name => :webservers}, {:group_name => :dbservers}]}
          ]).should be_true
        end
      end
    end

    describe "revoking ip access" do
      context "with a single option hash" do
        before do
          FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RevokeSecurityGroupIngress.*GroupName=test.*IpPermissions.1.FromPort=80.*IpPermissions.1.IpProtocol=tcp.*IpPermissions.1.IpRanges.1.CidrIp=12.23.34.45%2F0.*IpPermissions.1.ToPort=80|, :body => fixture('ec2/authorize_group_access'), :status => 200)
        end

        it "should return true" do
          ec2.revoke_security_group_ingress('test', [{:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}]}])
        end
      end

      context "with an array of option hashes" do
        before do
          FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RevokeSecurityGroupIngress.*GroupName=test.*IpPermissions.1.FromPort=80.*IpPermissions.1.IpProtocol=tcp.*IpPermissions.1.IpRanges.1.CidrIp=12.23.34.45%2F0.*IpPermissions.1.ToPort=80.*IpPermissions.2.FromPort=22.*IpPermissions.2.IpProtocol=tcp.*IpPermissions.2.IpRanges.1.CidrIp=12.23.34.45%2F0.*IpPermissions.2.IpRanges.2.CidrIp=12.34.56.78%2F0.*IpPermissions.2.ToPort=22|, :body => fixture('ec2/authorize_group_access'), :status => 200)
        end

        it "should return true" do
          ec2.revoke_security_group_ingress('test', [
            {:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}]},
            {:ip_protocol => :tcp, :from_port => 22, :to_port => 22, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}, {:cidr_ip => '12.34.56.78/0'}]}
          ])
        end
      end
    end

    describe "revoking both group and ip access" do
      context "with a single call" do
        before do
          FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RevokeSecurityGroupIngress.*GroupName=test.*IpPermissions.1.FromPort=80.*IpPermissions.1.IpProtocol=tcp.*IpPermissions.1.IpRanges.1.CidrIp=12.23.34.45%2F0.*IpPermissions.1.ToPort=80.*IpPermissions.2.FromPort=22.*IpPermissions.2.Groups.1.GroupName=webservers.*IpPermissions.2.IpProtocol=tcp.*IpPermissions.2.ToPort=22|, :body => fixture('ec2/authorize_group_access'), :status => 200)
        end

        it "should return true" do
          ec2.revoke_security_group_ingress('test', [
            {:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}]},
            {:ip_protocol => :tcp, :from_port => 22, :to_port => 22, :groups => [{:group_name => 'webservers'}]}
          ])
        end
      end
    end

    describe "sending both ip and user/group options to an authorization request" do
      it "should raise an error" do
        expect { ec2.authorize_security_group_ingress('test', [{:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}], :groups => [{:group_name => :webservers}]}]) }.to raise_error(ArgumentError)
      end
    end

    describe "including a wrong protocol in an authorization request" do
      it "should raise an error" do
        expect { ec2.authorize_security_group_ingress('test', [{:ip_protocol => :test, :from_port => 80, :to_port => 80, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}]}]) }.to raise_error(ArgumentError)
      end
    end

    describe "sending both ip and user/group options to a revokation request" do
      it "should raise an error" do
        expect { ec2.authorize_security_group_ingress('test', [{:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}], :groups => [{:group_name => :webservers}]}]) }.to raise_error(ArgumentError)
      end
    end

    describe "including a wrong protocol in a revokation request" do
      it "should raise an error" do
        expect { ec2.authorize_security_group_ingress('test', [{:ip_protocol => :test, :from_port => 80, :to_port => 80, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}]}]) }.to raise_error(ArgumentError)
      end
    end

    describe "a security group" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeSecurityGroups.*GroupName.1=default|, :body => fixture('ec2/security_groups'), :status => 200)
      end

      let(:security_group) { ec2.security_group('default') }

      it "should be able to authorize a group" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AuthorizeSecurityGroupIngress.*GroupName=default.*IpPermissions.1.FromPort=80.*IpPermissions.1.Groups.1.GroupName=webservers.*IpPermissions.1.IpProtocol=tcp.*IpPermissions.1.ToPort=80|, :body => fixture('ec2/authorize_group_access'), :status => 200)

        security_group.authorize({:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :groups => [{:group_name => :webservers}]}).should be_true
      end

      it "should be able to authorize ip access" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AuthorizeSecurityGroupIngress.*GroupName=default.*IpPermissions.1.FromPort=80.*IpPermissions.1.IpProtocol=tcp.*IpPermissions.1.IpRanges.1.CidrIp=12.23.34.45%2F0.*IpPermissions.1.ToPort=80.*IpPermissions.2.FromPort=22.*IpPermissions.2.IpProtocol=tcp.*IpPermissions.2.IpRanges.1.CidrIp=12.23.34.45%2F0.*IpPermissions.2.IpRanges.2.CidrIp=12.34.56.78%2F0.*IpPermissions.2.ToPort=22|, :body => fixture('ec2/authorize_group_access'), :status => 200)

        security_group.authorize([
          {:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}]},
          {:ip_protocol => :tcp, :from_port => 22, :to_port => 22, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}, {:cidr_ip => '12.34.56.78/0'}]}
        ])
      end

      it "should be able to revoke a group" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RevokeSecurityGroupIngress.*GroupName=default.*IpPermissions.1.FromPort=80.*IpPermissions.1.Groups.1.GroupName=webservers.*IpPermissions.1.IpProtocol=tcp.*IpPermissions.1.ToPort=80.*IpPermissions.2.FromPort=22.*IpPermissions.2.Groups.1.GroupName=webservers.*IpPermissions.2.Groups.2.GroupName=dbservers.*IpPermissions.2.IpProtocol=tcp.*IpPermissions.2.ToPort=22|, :body => fixture('ec2/authorize_group_access'), :status => 200)

        security_group.revoke([
          {:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :groups => [{:group_name => :webservers}]},
          {:ip_protocol => :tcp, :from_port => 22, :to_port => 22, :groups => [{:group_name => :webservers}, {:group_name => :dbservers}]}
        ]).should be_true
      end

      it "should be able to revoke ip access" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RevokeSecurityGroupIngress.*GroupName=default.*IpPermissions.1.FromPort=80.*IpPermissions.1.IpProtocol=tcp.*IpPermissions.1.IpRanges.1.CidrIp=12.23.34.45%2F0.*IpPermissions.1.ToPort=80|, :body => fixture('ec2/authorize_group_access'), :status => 200)

        security_group.revoke([{:ip_protocol => :tcp, :from_port => 80, :to_port => 80, :ip_ranges => [{:cidr_ip => '12.23.34.45/0'}]}])
      end

      it "should be able to delete itself" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DeleteSecurityGroup.*GroupName=default|, :body => fixture('ec2/delete_security_group'), :status => 200)

        security_group.delete.should be_true
      end
    end
  end
end
