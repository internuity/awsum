require 'spec_helper'

module Awsum
  describe Ec2::RegisterImageParser do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::RegisterImageParser.new(ec2) }
    let(:result) { parser.parse(fixture('ec2/register_image')) }

    it "should return an image id" do
      result.should == 'ami-4782652e'
    end
  end
end
