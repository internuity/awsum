require 'spec_helper'

module Awsum
  describe Ec2 do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }

    describe "creating a tag" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=CreateTags.*ResourceId.1=ari-f9c22690.*Tag.1.Key=name.*Tag.1.Value=Test|, :status => 200)
      end

      let(:result) { ec2.create_tags 'ari-f9c22690', :name => 'Test' }

      it "should return true" do
        result.should be_true
      end
    end

    describe "retrieving a list of tags" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeTags|, :body => fixture('ec2/tags'), :status => 200)
      end

      let(:result) { ec2.tags }

      it "should return an array of tags" do
        result.first.should be_a(Awsum::Ec2::Tag)
      end
    end

    describe "retrieving a list of tags with a filter" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeTags.*Filter.1.Name=key.*Filter.1.Value.1=name|, :body => fixture('ec2/tags'), :status => 200)
      end

      let(:result) { ec2.tags(:key => :name) }

      it "should return an array of tags" do
        result.first.should be_a(Awsum::Ec2::Tag)
      end
    end
  end
end
