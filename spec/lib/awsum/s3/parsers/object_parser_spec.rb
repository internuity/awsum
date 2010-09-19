require 'spec_helper'

module Awsum
  describe S3::ObjectParser do

    subject { S3.new('abc', 'xyz') }
    let(:s3) { subject }
    let(:parser) { Awsum::S3::ObjectParser.new(s3) }
    let(:result) { parser.parse(fixture('s3/keys')) }

    it "should return an array of object" do
      result.should be_a(Array)
    end

    context "the first object" do
      let(:object) { result.first }

      {
        :key           => 'test/photo1.jpg',
        :last_modified => Time.parse('2008-12-07T13:47:59.000Z'),
        :etag          => '"03bde534951a1c099724f569a53acb1e"',
        :size          => 203841,
        :storage_class => 'STANDARD'
      }.each do |key, value|
        it "should have the correct #{key}" do
          object.send(key).should == value
        end
      end

      #TODO: This should be object.owner.name
      it "should have the correct owner name" do
        object.owner['name'].should == 'AAAAAA'
      end

      #TODO: This should be object.owner.id
      it "should have the correct owner id" do
        object.owner['id'].should == '1111111111111111111111111111111111111111111111111111111111111111'
      end
    end
  end
end
