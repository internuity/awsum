require 'spec_helper'

module Awsum
  describe S3 do

    subject { S3.new('abc', 'xyz') }
    let(:s3) { subject }

    describe "naming a bucket" do
      it "should not have an ip address style name" do
        expect { s3.create_bucket('192.168.2.1') }.to raise_error
      end

      it "should not start with punctuation" do
        expect { s3.create_bucket('-name') }.to raise_error
        expect { s3.create_bucket('.name') }.to raise_error
        expect { s3.create_bucket('_name') }.to raise_error
      end

      it "should not end with a dash" do
        expect { s3.create_bucket('name-') }.to raise_error
      end

      it "should not have a dash to the left of a period" do
        expect { s3.create_bucket('name-.test') }.to raise_error
      end

      it "should not have a dash to the right of a period" do
        expect { s3.create_bucket('name.-test') }.to raise_error
      end

      it "should not be shorter than 3 characters" do
        expect { s3.create_bucket('ab') }.to raise_error
      end

      it "should not be longer than 63 characters" do
        expect { s3.create_bucket((0..63).collection{'a'}.join) }.to raise_error
      end

      it "should be able to start with a number" do
        FakeWeb.register_uri(:put, 'https://2name.s3.amazonaws.com/', :body => '', :status => 200)

        expect { s3.create_bucket('2name') }.should_not raise_error
      end

      it "should otherwise succeed" do
        FakeWeb.register_uri(:put, 'https://test.s3.amazonaws.com/', :body => '', :status => 200)

        expect { s3.create_bucket('test') }.should_not raise_error
      end
    end

    describe "retrieving a list of buckets" do
      before do
        FakeWeb.register_uri(:get, 'https://s3.amazonaws.com/', :body => fixture('s3/buckets'), :status => 200)
      end

      let(:buckets) { s3.buckets }

      it "should return an array of buckets" do
        buckets.first.should be_a(Awsum::S3::Bucket)
      end
    end

    describe "deleting a bucket" do
      before do
        FakeWeb.register_uri(:delete, 'https://test.s3.amazonaws.com/', :body => '', :status => 200)
      end

      it "should return true" do
        s3.delete_bucket('test').should be_true
      end
    end

    describe "a bucket" do
      let(:bucket) { Awsum::S3::Bucket.new(s3, 'test', Time.now) }

      it "should be able to delete itself" do
        FakeWeb.register_uri(:delete, 'https://test.s3.amazonaws.com/', :body => '', :status => 200)

        bucket.delete.should be_true
      end

      it "should be able to delete itself even if it contains objects" do
        FakeWeb.register_uri(:get, 'https://test.s3.amazonaws.com/', :body => fixture('s3/keys'), :status => 200)
        ['test/photo1.jpg', 'test/photo2.jpg'].each do |key|
          FakeWeb.register_uri(:delete, "https://test.s3.amazonaws.com/#{key}", :body => '', :status => 200)
        end
        FakeWeb.register_uri(:delete, 'https://test.s3.amazonaws.com/', :body => '', :status => 200)

        bucket.delete!.should be_true
      end
    end
  end
end
