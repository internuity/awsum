require 'spec_helper'

module Awsum
  describe Ec2::ReservedInstanceParser do
    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::ReservedInstanceParser.new(ec2) }
    let(:result) { parser.parse(fixture('ec2/reserved_instances')) }

    it "should return an array of reserved instances" do
      result.should be_a(Array)
    end

    context "the first reserved instance" do
      let(:reserved_instance) { result.first }

      {
        :id                  => '1ba8e2e3-e6f7-4ef5-8c6c-6c6e4fad0a56',
        :instance_type       => 'm1.large',
        :availability_zone   => 'us-east-1a',
        :start               => Time.parse('2009-03-17T09:57:20.668Z'),
        :duration            => 31536000,
        :fixed_price         => 0.12,
        :usage_price         => 1300.0,
        :instance_count      => 1,
        :product_description => 'Linux/UNIX',
        :state               => 'payment-pending'
      }.each do |key, value|
        it "should have the correct #{key}" do
          reserved_instance.send(key).should == value
        end
      end
    end
  end
end
