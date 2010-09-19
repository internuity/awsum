require 'spec_helper'

module Awsum
  describe Ec2::AddressParser do
    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::AddressParser.new(ec2) }

    describe "parsing the result of a call to DescribeAddresses" do
      let(:result) { parser.parse(fixture('ec2/addresses')) }

      it "should return an array of addresses" do
        result.should be_a(Array)
      end

      context "the first address" do
        let(:address) { result.first }

        {
          :public_ip    =>  '127.0.0.1',
          :instance_id  =>  'i-3f1cc856'
        }.each do |key, value|
          it "should have the correct #{key}" do
            address.send(key).should == value
          end
        end
      end
    end

    describe "parsing the result of a call to AllocateAddress" do
      let(:result) { parser.parse(fixture('ec2/allocate_address')) }

      it "should return an array of addresses" do
        result.should be_a(Array)
      end

      context "the address" do
        let(:address) { result.first }

        {
          :public_ip    =>  '127.0.0.1',
          :instance_id  =>  nil
        }.each do |key, value|
          it "should have the correct #{key}" do
            address.send(key).should == value
          end
        end
      end
    end
  end
end
