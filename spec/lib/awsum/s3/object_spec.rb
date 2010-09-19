require 'spec_helper'

module Awsum
  describe S3 do

    subject { S3.new('abc', 'xyz') }
    let(:s3) { subject }

    describe "creating an object" do
      it "should be possible with a string" do
        FakeWeb.register_uri(:put, 'https://test.s3.amazonaws.com/test.txt', :body => '', :status => 200)

        s3.create_object('test', 'test.txt', 'Some text').should be_true
      end

      it "should be possible with a IO object" do
        FakeWeb.register_uri(:put, 'https://test.s3.amazonaws.com/test.txt', :body => '', :status => 200)

        s3.create_object('test', 'test.txt', StringIO.new('Some text')).should be_true
      end
    end

    describe "deleting an object" do
      it "should return true" do
        FakeWeb.register_uri(:delete, 'https://test.s3.amazonaws.com/test.txt', :body => '', :status => 200)

        s3.delete_object('test', 'test.txt').should be_true
      end
    end

    describe "copying an object" do
      it "should be possible to a different bucket with the same key" do
        s3.should_receive(:send_s3_request).with("PUT", {:bucket=>"test2", :headers=>{"x-amz-copy-source"=>"/test/test.txt", "x-amz-metadata-directive"=>"COPY"}, :data=>nil, :key=>"test.txt"})

        s3.copy_object('test', 'test.txt', 'test2')
      end

      it "should be possible within the same bucket with a different key" do
        s3.should_receive(:send_s3_request).with("PUT", {:bucket=>"test", :headers=>{"x-amz-copy-source"=>"/test/test.txt", "x-amz-metadata-directive"=>"COPY"}, :data=>nil, :key=>"test2.txt"})

        s3.copy_object('test', 'test.txt', nil, 'test2.txt')
      end

      it "should allow replacing headers and meta-data" do
        s3.should_receive(:send_s3_request).with("PUT", {:bucket=>"test", :headers=>{"x-amz-copy-source"=>"/test/test.txt", "New-Header"=>"two", "x-amz-metadata-directive"=>"REPLACE"}, :data=>nil, :key=>"test.txt"})

        s3.copy_object('test', 'test.txt', nil, nil, {'New-Header' => 'two'})
      end

      it "should not allow within the same bucket, with the same key name and no changed headers" do
        expect { s3.copy_object('test', 'test.txt') }.to raise_error
      end

      it "should raise an error if the copy fails" do
        FakeWeb.register_uri(:put, 'https://test2.s3.amazonaws.com/test.txt', :body => fixture('s3/copy_failure'), :status => 200)

        expect { s3.copy_object('test', 'test.txt', 'test2') }.to raise_error(Awsum::Error)
      end
    end

    describe "an object" do
      let(:object) { Awsum::S3::Object.new(s3, 'test', 'test.txt', Time.now, 'XXXXX', 234, 'AAAAAA', 'STANDARD') }

      it "should be able to delete itself" do
        FakeWeb.register_uri(:delete, 'https://test.s3.amazonaws.com/test.txt', :body => '', :status => 200)

        object.delete.should be_true
      end

      it "should be able to copy itself to a different key" do
        FakeWeb.register_uri(:put, 'https://test.s3.amazonaws.com/test2.txt', :body => '', :status => 200)

        object.copy('test2.txt').should be_true
      end

      it "should be able to rename itself" do
        FakeWeb.register_uri(:put, 'https://test.s3.amazonaws.com/test2.txt', :body => '', :status => 200)
        FakeWeb.register_uri(:delete, 'https://test.s3.amazonaws.com/test.txt', :body => '', :status => 200)

        object.rename('test2.txt').should be_true
      end

      it "should be able to move itself" do
        FakeWeb.register_uri(:put, 'https://test.s3.amazonaws.com/test2.txt', :body => '', :status => 200)
        FakeWeb.register_uri(:delete, 'https://test.s3.amazonaws.com/test.txt', :body => '', :status => 200)

        object.move('test2.txt').should be_true
      end

      it "should be able to copy itself to another bucket" do
        FakeWeb.register_uri(:put, 'https://another.s3.amazonaws.com/test.txt', :body => '', :status => 200)

        object.copy_to('another').should be_true
      end

      it "should be able to move itself to another bucket" do
        FakeWeb.register_uri(:put, 'https://another.s3.amazonaws.com/test.txt', :body => '', :status => 200)
        FakeWeb.register_uri(:delete, 'https://test.s3.amazonaws.com/test.txt', :body => '', :status => 200)

        object.move_to('another').should be_true
      end

      #TODO: Provide better specs on headers
      it "should be able to return it's headers" do
        FakeWeb.register_uri(:head, 'https://test.s3.amazonaws.com/test.txt', :body => '', :status => 200)

        object.headers.should be_a(Awsum::S3::Headers)
      end

      it "should be able to return it's data" do
        FakeWeb.register_uri(:get, 'https://test.s3.amazonaws.com/test.txt', :body => 'The data', :status => 200)

        object.data.should == 'The data'
      end

      it "should be able to return it's data in chunks" do
        FakeWeb.register_uri(:get, 'https://test.s3.amazonaws.com/test.txt', :body => 'The data', :status => 200)

        data = ''
        object.data do |chunk|
          data << chunk
        end

        data.should == 'The data'
      end
    end
  end
end
