require 'spec_helper'

module Awsum
  describe Ec2 do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }

    describe "purchasing a reserved instance" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=PurchaseReservedInstancesOffering.*InstanceCount=1.*ReservedInstancesOfferingId=e5a2ff3b-f6eb-4b4e-83f8-b879d7060257|, :body => fixture('ec2/purchase_reserved_instances_offering'), :status => 200)
      end

      let(:result) { ec2.purchase_reserved_instances_offering 'e5a2ff3b-f6eb-4b4e-83f8-b879d7060257' }

      it "should return an array of reserved instance ids" do
        result.should == ['1ba8e2e3-e6f7-4ef5-8c6c-6c6e4fad0a56']
      end
    end

    describe "retrieving a list of reserved instances" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeReservedInstances|, :body => fixture('ec2/reserved_instances'), :status => 200)
      end

      let(:result) { ec2.reserved_instances }

      it "should return an array of reserverd instances" do
        result.first.should be_a(Awsum::Ec2::ReservedInstance)
      end
    end

    describe "retrieving a single reserved instance" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeReservedInstances.*ReservedInstanceId.1=1ba8e2e3-e6f7-4ef5-8c6c-6c6e4fad0a56|, :body => fixture('ec2/reserved_instances'), :status => 200)
      end

      let(:result) { ec2.reserved_instance '1ba8e2e3-e6f7-4ef5-8c6c-6c6e4fad0a56' }

      it "should return a reserverd instance" do
        result.should be_a(Awsum::Ec2::ReservedInstance)
      end
    end
  end
end
