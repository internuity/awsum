require 'spec_helper'

module Awsum
  describe Ec2::AvailabilityZoneParser do
    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::AvailabilityZoneParser.new(ec2) }
    let(:result) { parser.parse(fixture('ec2/availability_zones')) }

    it "should return an array of availability zones" do
      result.should be_a(Array)
    end

    context "the first availability zone" do
      let(:availability_zone) { result.first }

      {
        :name        =>  'eu-west-1a',
        :state       =>  'available',
        :region_name => 'eu-west-1'
      }.each do |key, value|
        it "should have the correct #{key}" do
          availability_zone.send(key).should == value
        end
      end
    end
  end
end
