require 'spec_helper'

module Awsum
  describe Ec2 do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }

    describe "retrieving a list of key pairs" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeKeyPairs|, :body => fixture('ec2/key_pairs'), :status => 200)
      end

      let(:result) { ec2.key_pairs }

      it "should return an array of key pairs" do
        result.first.should be_a(Awsum::Ec2::KeyPair)
      end
    end

    describe "retrieving a single key pair by name" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeKeyPairs.*KeyName.1=gsg_keypair|, :body => fixture('ec2/key_pairs'), :status => 200)
      end

      let(:result) { ec2.key_pair 'gsg_keypair' }

      it "should return a key pair" do
        result.should be_a(Awsum::Ec2::KeyPair)
      end
    end

    describe "creating a key pair" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=CreateKeyPair.*KeyName=test-keypair|, :body => fixture('ec2/key_pairs'), :status => 200)
      end

      let(:result) { ec2.create_key_pair('test-keypair') }

      it "should return a key pair" do
        result.should be_a(Awsum::Ec2::KeyPair)
      end
    end

    describe "deleting a key pair" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DeleteKeyPair.*KeyName=test-keypair|, :body => fixture('ec2/key_pairs'), :status => 200)
      end

      it "should return a key pair" do
        ec2.delete_key_pair('test-keypair').should be_true
      end
    end
  end
end
