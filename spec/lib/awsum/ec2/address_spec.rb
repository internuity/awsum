require 'spec_helper'

module Awsum
  describe Ec2 do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }

    describe "retrieving a list of addresses" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeAddresses|, :body => fixture('ec2/addresses'), :status => 200)
      end

      let(:result) { ec2.addresses }

      it "should return an array of addresses" do
        result.first.should be_a(Awsum::Ec2::Address)
      end
    end

    describe "allocating an address" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AllocateAddress|, :body => fixture('ec2/allocate_address'), :status => 200)
      end

      let(:result) { ec2.allocate_address }

      it "should return an address" do
        result.should be_a(Awsum::Ec2::Address)
      end
    end

    describe "associating an address" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AssociateAddress.*InstanceId=i-ABCDEF.*PublicIp=127.0.0.1|, :body => fixture('ec2/associate_address'), :status => 200)
      end

      it "should return true" do
        ec2.associate_address('i-ABCDEF', '127.0.0.1').should be_true
      end
    end

    describe "disassociating an address" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DisassociateAddress.*PublicIp=127.0.0.1|, :body => fixture('ec2/disassociate_address'), :status => 200)
      end

      it "should return true" do
        ec2.disassociate_address('127.0.0.1').should be_true
      end
    end

    describe "releasing an address" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeAddresses.*PublicIp.1=127.0.0.1|, :body => fixture('ec2/unassociated_address'), :status => 200)

        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=ReleaseAddress.*PublicIp=127.0.0.1|, :body => fixture('ec2/release_address'), :status => 200)
      end

      it "should return true" do
        ec2.release_address('127.0.0.1').should be_true
      end
    end

    describe "trying to release an address that is associated" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeAddresses.*PublicIp.1=127.0.0.1|, :body => fixture('ec2/addresses'), :status => 200)
      end

      it "should return true" do
        expect { ec2.release_address('127.0.0.1') }.to raise_error
      end
    end

    describe "forcing the release of an address" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=ReleaseAddress.*PublicIp=127.0.0.1|, :body => fixture('ec2/release_address'), :status => 200)
      end

      it "should return true" do
        ec2.release_address!('127.0.0.1').should be_true
      end
    end

    describe "an associated address" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeAddresses.*PublicIp.1=127.0.0.1|, :body => fixture('ec2/addresses'), :status => 200)
      end

      let(:address) { ec2.address('127.0.0.1') }

      it "should return the instance it's associated with" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeInstances.*InstanceId.1=i-3f1cc856|, :body => fixture('ec2/instances'), :status => 200)

        address.instance.should be_a(Awsum::Ec2::Instance)
      end

      it "should not be able to associate itself with an instance" do
        expect { address.associate('i-123456') }.to raise_error
      end

      it "should be able to force an association with an instance" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AssociateAddress.*InstanceId=i-123456.*PublicIp=127.0.0.1|, :body => fixture('ec2/unassociated_address'), :status => 200)

        address.associate!('i-123456').should be_true
      end

      it "should be able to disassociate itself from instance" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DisassociateAddress.*PublicIp=127.0.0.1|, :body => fixture('ec2/unassociated_address'), :status => 200)

        address.disassociate.should be_true
      end

      it "should raise an error if trying to release itself" do
        expect { address.release }.to raise_error
      end

      it "should be able to release itself by force" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=ReleaseAddress.*PublicIp=127.0.0.1|, :body => fixture('ec2/unassociated_address'), :status => 200)

        address.release!.should be_true
      end
    end

    describe "an unassociated address" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeAddresses.*PublicIp.1=127.0.0.1|, :body => fixture('ec2/unassociated_address'), :status => 200)
      end

      let(:address) { ec2.address('127.0.0.1') }

      it "should be able to associate itself with an instance" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AssociateAddress.*InstanceId=i-123456.*PublicIp=127.0.0.1|, :body => fixture('ec2/unassociated_address'), :status => 200)

        address.associate('i-123456').should be_true
      end

      it "should raise an error if trying to disassociate itself from an instance" do
        expect { address.disassociate }.to raise_error
      end

      it "should be able to release itself" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=ReleaseAddress.*PublicIp=127.0.0.1|, :body => fixture('ec2/unassociated_address'), :status => 200)

        address.release.should be_true
      end
    end
  end
end
