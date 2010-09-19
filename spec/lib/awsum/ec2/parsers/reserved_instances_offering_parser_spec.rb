require 'spec_helper'

module Awsum
  describe Ec2::ReservedInstancesOfferingParser do
    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::ReservedInstancesOfferingParser.new(ec2) }
    let(:result) { parser.parse(fixture('ec2/reserved_instances_offerings')) }

    it "should return an array of reserved instances offerings" do
      result.should be_a(Array)
    end

    context "the first offering" do
      let(:offering) { result.first }

      {
        :id                  => 'e5a2ff3b-f6eb-4b4e-83f8-b879d7060257',
        :instance_type       => 'c1.medium',
        :availability_zone   => 'us-east-1b',
        :duration            => 94608000,
        :fixed_price         => 1000.0,
        :usage_price         => 0.06,
        :product_description => 'Linux/UNIX'
      }.each do |key, value|
        it "should have the correct #{key}" do
          offering.send(key).should == value
        end
      end
    end
  end
end
