require 'spec_helper'

module Awsum
  describe Ec2 do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }

    describe "retrieving a list of availability zones" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeAvailabilityZones|, :body => fixture('ec2/availability_zones'), :status => 200)
      end

      let(:result) { ec2.availability_zones }

      it "should return an array of availability zones" do
        result.first.should be_a(Awsum::Ec2::AvailabilityZone)
      end
    end
  end
end
