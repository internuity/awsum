require 'spec_helper'

module Awsum
  describe Ec2 do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }

    describe "retrieving a list of available reserved instance offerrings" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeReservedInstancesOfferings|, :body => fixture('ec2/reserved_instances_offerings'), :status => 200)
      end

      let(:result) { ec2.reserved_instances_offerings }

      it "should return an array of reserverd instances offerings" do
        result.first.should be_a(Awsum::Ec2::ReservedInstancesOffering)
      end
    end

    describe "retrieving a single reserved instance offerring" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeReservedInstancesOfferings.*ReservedInstancesOfferingId.1=e5a2ff3b-f6eb-4b4e-83f8-b879d7060257|, :body => fixture('ec2/reserved_instances_offerings'), :status => 200)
      end

      let(:result) { ec2.reserved_instances_offering 'e5a2ff3b-f6eb-4b4e-83f8-b879d7060257' }

      it "should return a reserverd instances offering" do
        result.should be_a(Awsum::Ec2::ReservedInstancesOffering)
      end
    end
  end
end
