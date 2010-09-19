require 'spec_helper'

module Awsum
  describe Ec2::RegionParser do
    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::RegionParser.new(ec2) }
    let(:result) { parser.parse(fixture('ec2/regions')) }

    it "should return an array of regions" do
      result.should be_a(Array)
    end

    context "the first region" do
      let(:region) { result.first }

      {
        :name       =>  'eu-west-1',
        :end_point  =>  'eu-west-1.ec2.amazonaws.com'
      }.each do |key, value|
        it "should have the correct #{key}" do
          region.send(key).should == value
        end
      end
    end
  end
end
