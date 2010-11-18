require 'spec_helper'

module Awsum
  describe Ec2::TagParser do
    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::TagParser.new(ec2) }
    let(:result) { parser.parse(fixture('ec2/tags')) }

    it "should return an array of tags" do
      result.should be_a(Array)
    end

    context "the first tag" do
      let(:tag) { result.first }

      {
        :resource_id   => 'ari-f9c22690',
        :resource_type => 'image',
        :key           => 'name',
        :value         => 'Test'
      }.each do |key, value|
        it "should have the correct #{key}" do
          tag.send(key).should == value
        end
      end
    end
  end
end
