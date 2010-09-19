require 'spec_helper'

module Awsum
  describe Ec2::InstanceParser do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::InstanceParser.new(ec2) }
    let(:result) { parser.parse(fixture('ec2/instances')) }

    it "should return an array of instances" do
      result.should be_a(Array)
    end

    context "the first instance" do
      let(:instance) { result.first }

      {
        :id                 => 'i-3f1cc856',
        :private_dns_name   => 'ip-10-255-255-255.ec2.internal',
        :dns_name           => 'ec2-75-255-255-255.compute-1.amazonaws.com',
        :key_name           => 'gsg-keypair',
        :launch_index       => 0,
        :type               => 'm1.small',
        :availability_zone  => 'us-east-1b',
        :launch_time        => Time.parse('2008-06-18T12:51:52.000Z'),
        :state              => {:code => 0, :name => 'pending'}
      }.each do |key, value|
        it "should have the correct #{key}" do
          instance.send(key).should == value
        end
      end
    end

    context "the second instance" do
      let(:instance) { result[1] }

      it "should have the correct state" do
        instance.state.should == {:code => 16, :name => 'running'}
      end
    end
  end

  describe "Ec2::InstanceParser with the result of RunInstances" do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::InstanceParser.new(ec2) }
    let(:result) { parser.parse(fixture('ec2/run_instances')) }

    it "should return an array of instances" do
      result.should be_a(Array)
    end

    context "the first instance" do
      let(:instance) { result.first }

      {
        :id                 => 'i-f92fa890',
        :private_dns_name   => nil,
        :dns_name           => nil,
        :key_name           => nil,
        :launch_index       => 0,
        :type               => 'm1.small',
        :availability_zone  => 'us-east-1b',
        :launch_time        => Time.parse('2009-01-11T13:09:01.000Z'),
        :state              => {:code => 0, :name => 'pending'}
      }.each do |key, value|
        it "should have the correct #{key}" do
          instance.send(key).should == value
        end
      end
    end
  end
end
