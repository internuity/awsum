require 'spec_helper'

module Awsum
  describe Ec2::PurchaseReservedInstancesOfferingParser do
    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::PurchaseReservedInstancesOfferingParser.new(ec2) }
    let(:result) { parser.parse(fixture('ec2/purchase_reserved_instances_offering')) }

    it "should return an array of reserved instance ids" do
      result.first.should == '1ba8e2e3-e6f7-4ef5-8c6c-6c6e4fad0a56'
    end
  end
end
