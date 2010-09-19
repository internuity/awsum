require 'spec_helper'

module Awsum
  describe Ec2::SnapshotParser do
    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::SnapshotParser.new(ec2) }
    let(:result) { parser.parse(fixture('ec2/snapshots')) }

    it "should return an array of snapshot" do
      result.should be_a(Array)
    end

    context "the first snapshot" do
      let(:snapshot) { result.first }

      {
        :id          => 'snap-747c911d',
        :volume_id   => 'vol-44d6322d',
        :status      => 'completed',
        :start_time  => Time.parse('2009-01-15T03:59:26.000Z'),
        :progress    => '100%'
      }.each do |key, value|
        it "should have the correct #{key}" do
          snapshot.send(key).should == value
        end
      end
    end
  end
end
