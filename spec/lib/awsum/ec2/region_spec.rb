require 'spec_helper'

module Awsum
  describe Ec2 do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }

    describe "retrieving a list of regions" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeRegions|, :body => fixture('ec2/regions'), :status => 200)
      end

      let(:result) { ec2.regions }

      it "should return an array of regions" do
        result.first.should be_a(Awsum::Ec2::Region)
      end
    end

    describe "retrieving a single region" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeRegions.*RegionName.1=eu-west-1|, :body => fixture('ec2/regions'), :status => 200)
      end

      let(:result) { ec2.region 'eu-west-1' }

      it "should return a region" do
        result.should be_a(Awsum::Ec2::Region)
      end
    end

    describe "a region" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeRegions.*RegionName.1=eu-west-1|, :body => fixture('ec2/regions'), :status => 200)
      end

      let(:region) { ec2.region 'eu-west-1'}

      it "should be able to list it's availability zones" do
        FakeWeb.register_uri(:get, %r|https://eu-west-1\.ec2\.amazonaws\.com/?.*Action=DescribeAvailabilityZones|, :body => fixture('ec2/availability_zones'), :status => 200)

        region.availability_zones.first.should be_a(Awsum::Ec2::AvailabilityZone)
      end

      it "should work in block mode (with a supplied parameter)" do
        FakeWeb.register_uri(:get, %r|https://eu-west-1\.ec2\.amazonaws\.com/?.*Action=DescribeAvailabilityZones|, :body => fixture('ec2/availability_zones'), :status => 200)

        zones = ec2.region('eu-west-1') do |region|
          region.availability_zones
        end

        zones.first.should be_a(Awsum::Ec2::AvailabilityZone)
      end

      it "should work in block mode (without a supplied parameter)" do
        FakeWeb.register_uri(:get, %r|https://eu-west-1\.ec2\.amazonaws\.com/?.*Action=DescribeAvailabilityZones|, :body => fixture('ec2/availability_zones'), :status => 200)

        zones = ec2.region('eu-west-1') do
          availability_zones
        end

        zones.first.should be_a(Awsum::Ec2::AvailabilityZone)
      end

      it "should receive ec2 methods (pass-through)" do
        FakeWeb.register_uri(:get, %r|https://eu-west-1\.ec2\.amazonaws\.com/?.*Action=RunInstances.*ImageId=9-123456789|, :body => fixture('ec2/run_instances'), :status => 200)

        region.run_instances('9-123456789').should be_true
      end
    end
  end
end
