require 'spec_helper'

module Awsum
  describe Ec2::ImageParser do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::ImageParser.new(ec2) }
    let(:result) { parser.parse(fixture('ec2/images')) }

    it "should return an array of images" do
      result.should be_a(Array)
    end

    context "the first image" do
      let(:image) { result.first }

      {
        :id           => 'aki-0d9f7b64',
        :location     => 'oracle_linux_kernels/2.6.18-53.1.13.9.1.el5xen/vmlinuz-2.6.18-53.1.13.9.1.el5xen.manifest.xml',
        :state        => 'available',
        :owner        => '725966715235',
        :architecture => 'x86_64',
        :type         => 'kernel'
      }.each do |key, value|
        it "should have the correct #{key}" do
          image.send(key).should == value
        end
      end

      it "should be marked as public" do
        image.should be_public
      end
    end

    context "the second image" do
      let(:image) { result[1] }

      it "should have the correct id" do
        image.id.should == 'aki-25de3b4c'
      end

      it "should have an array of product codes" do
        image.product_codes.should be_a(Array)
      end

      it "should have the correct product codes" do
        image.product_codes.first.should == '54DBF944'
      end
    end

    context "the third image" do
      let(:image) { result[2] }

      {
        :id          => 'ami-005db969',
        :kernel_id   => 'aki-b51cf9dc',
        :ramdisk_id  => 'ari-b31cf9da'
      }.each do |key, value|
        it "should have the correct #{key}" do
          image.send(key).should == value
        end
      end
    end
  end
end
