require 'spec_helper'

module Awsum
  describe Ec2::VolumeParser do
    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::VolumeParser.new(ec2) }
    let(:result) { parser.parse(fixture('ec2/volumes')) }

    it "should return an array of volumes" do
      result.should be_a(Array)
    end

    context "the first volume" do
      let(:volume) { result.first }

      {
        :id                => 'vol-44d6322d',
        :size              => 10,
        :snapshot_id       => nil,
        :availability_zone => 'us-east-1b',
        :status            => 'in-use',
        :create_time       => Time.parse('2009-01-14T03:57:08.000Z'),
        :instance_id       => 'i-3f1cc856',
        :device            => '/dev/sdb',
        :attachment_status => 'attached',
        :attach_time       => Time.parse('2009-01-14T04:34:35.000Z')
      }.each do |key, value|
        it "should have the correct #{key}" do
          volume.send(key).should == value
        end
      end
    end
  end
end
