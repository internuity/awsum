require 'spec_helper'

module Awsum
  describe Ec2 do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }

    describe "retrieving a list of images" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeImages|, :body => fixture('ec2/images'), :status => 200)
      end

      let(:result) { ec2.images }

      it "should return an array of images" do
        result.first.should be_a(Awsum::Ec2::Image)
      end
    end

    describe "retrieving a list of owned images" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeImages.*Owner.1=self|, :body => fixture('ec2/images'), :status => 200)
      end

      let(:result) { ec2.my_images }

      it "should return an array of images" do
        result.first.should be_a(Awsum::Ec2::Image)
      end
    end

    describe "retrieving an image by id" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeImages.*ImageId.1=ari-f9c22690|, :body => fixture('ec2/image'), :status => 200)
      end

      let(:result) { ec2.image('ari-f9c22690') }

      it "should return the image" do
        result.should be_a(Awsum::Ec2::Image)
      end
    end

    describe "retrieving a filtered list of images" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeImages.*Filter.1.Name=architecture.*Filter.1.Value.1=i386|, :body => fixture('ec2/images'), :status => 200)
      end

      let(:result) { ec2.images(:filter => {:architecture => 'i386'}) }

      it "should return an array of images" do
        result.first.should be_a(Awsum::Ec2::Image)
      end
    end

    describe "retrieving a filtered list of images with a complicated filter" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeImages.*Filter.1.Name=tag%3AName.*Filter.1.Value.1=Test.*Filter.2.Name=image-type.*Filter.2.Value.1=machine.*Filter.2.Value.2=kernel.*Filter.2.Value.3=ramdisk.*Filter.3.Name=architecture.*Filter.3.Value.1=i386|, :body => fixture('ec2/images'), :status => 200)
      end

      let(:result) { ec2.images(:filter => {:architecture => 'i386', 'tag:Name' => 'Test', 'image-type' => ['machine', 'kernel', 'ramdisk']}) }

      it "should return an array of images" do
        result.first.should be_a(Awsum::Ec2::Image)
      end
    end

    describe "retrieving a filtered list of images by tag" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeImages.*Filter.1.Name=tag%3Aname.*Filter.1.Value.1=Test|, :body => fixture('ec2/images'), :status => 200)
      end

      let(:result) { ec2.images(:tags => {:name => 'Test'}) }

      it "should return an array of images" do
        result.first.should be_a(Awsum::Ec2::Image)
      end
    end

    describe "retrieving a filtered list of owned images" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeImages.*Filter.1.Name=architecture.*Filter.1.Value.1=i386.*Owner.1=self|, :body => fixture('ec2/images'), :status => 200)
      end

      let(:result) { ec2.my_images(:filter => {:architecture => 'i386'}) }

      it "should return an array of images" do
        result.first.should be_a(Awsum::Ec2::Image)
      end
    end

    describe "retrieving a filtered list of owned images by tag" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeImages.*Filter.1.Name=tag%3Aname.*Filter.1.Value.1=Test.*Owner.1=self|, :body => fixture('ec2/images'), :status => 200)
      end

      let(:result) { ec2.my_images(:tags => {:name => 'Test'}) }

      it "should return an array of images" do
        result.first.should be_a(Awsum::Ec2::Image)
      end
    end

    describe "registering an image" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RegisterImage.*ImageLocation=s3.bucket.location|, :body => fixture('ec2/register_image'), :status => 200)
      end

      it "should be able to create an image" do
        image_id = ec2.register_image('s3.bucket.location')

        image_id.should == 'ami-4782652e'
      end
    end

    describe "deregistering an image" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DeregisterImage.*ImageId=ami-4782652e|, :body => fixture('ec2/deregister_image'), :status => 200)
      end

      it "should return true" do
        ec2.deregister_image('ami-4782652e').should be_true
      end
    end

    describe "an image" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeImages.*ImageId.1=ari-f9c22690|, :body => fixture('ec2/image'), :status => 200)
      end

      let(:image) { ec2.image('ari-f9c22690') }

      it "should be able to create an image" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RunInstances.*ImageId=ari-f9c22690|, :body => fixture('ec2/instance'), :status => 200)
        result = image.run
        result.first.should be_a(Awsum::Ec2::Instance)
      end

      it "should be able to deregister itself" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DeregisterImage.*ImageId=ari-f9c22690|, :body => fixture('ec2/deregister_image'), :status => 200)
        image.deregister.should be_true
      end

      it "should be able reregister itself" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DeregisterImage.*ImageId=ari-f9c22690|, :body => fixture('ec2/deregister_image'), :status => 200)
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RegisterImage.*ImageLocation=s3.bucket.location|, :body => fixture('ec2/register_image'), :status => 200)
        image.reregister.should be_true
      end
    end
  end
end
