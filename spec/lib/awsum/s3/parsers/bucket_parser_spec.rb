require 'spec_helper'

module Awsum
  describe S3::BucketParser do

    subject { S3.new('abc', 'xyz') }
    let(:s3) { subject }
    let(:parser) { Awsum::S3::BucketParser.new(s3) }
    let(:result) { parser.parse(fixture('s3/buckets')) }

    it "should return an array of buckets" do
      result.should be_a(Array)
    end

    context "the first bucket" do
      let(:bucket) { result.first }

      {
        :name => 'test-bucket',
        :creation_date => Time.parse('2008-12-04T16:08:03.000Z')
      }.each do |key, value|
        it "should have the correct #{key}" do
          bucket.send(key).should == value
        end
      end
    end

    context "the second bucket" do
      let(:bucket) { result[1] }

      {
        :name => 'another-test-bucket',
        :creation_date => Time.parse('2009-01-02T08:25:27.000Z')
      }.each do |key, value|
        it "should have the correct #{key}" do
          bucket.send(key).should == value
        end
      end
    end
  end
end
