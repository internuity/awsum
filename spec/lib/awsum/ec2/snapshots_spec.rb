require 'spec_helper'

module Awsum
  describe Ec2 do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }

    describe "creating a snapshot" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=CreateSnapshot.*Description=Test%20snapshot.*VolumeId=vol-44d6322d|, :body => fixture('ec2/create_snapshot'), :status => 200)
      end

      let(:result) { ec2.create_snapshot 'vol-44d6322d', :description => 'Test snapshot' }

      it "should return a snapshot" do
        result.should be_a(Awsum::Ec2::Snapshot)
      end
    end

    describe "creating a snapshot with tags" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=CreateSnapshot.*VolumeId=vol-44d6322d|, :body => fixture('ec2/create_snapshot'), :status => 200)

        ec2.should_receive(:create_tags).with('snap-747c911d', :name => 'Test')
      end

      let(:result) { ec2.create_snapshot 'vol-44d6322d', :tags => {:name => 'Test'} }

      it "should return a snapshot" do
        result.should be_a(Awsum::Ec2::Snapshot)
      end
    end

    describe "retrieving a snapshot" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeSnapshots.*SnapshotId.1=snap-747c911d|, :body => fixture('ec2/snapshots'), :status => 200)
      end

      let(:result) { ec2.snapshot 'snap-747c911d' }

      it "should return a snapshot" do
        result.should be_a(Awsum::Ec2::Snapshot)
      end
    end

    describe "retrieving a list of snapshots" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeSnapshots|, :body => fixture('ec2/snapshots'), :status => 200)
      end

      let(:result) { ec2.snapshots }

      it "should return a snapshot" do
        result.first.should be_a(Awsum::Ec2::Snapshot)
      end
    end

    describe "retrieving a list of snapshots with a filter" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeSnapshots.*Filter.1.Name=Name.*Filter.1.Value.1=Test|, :body => fixture('ec2/snapshots'), :status => 200)
      end

      let(:result) { ec2.snapshots(:filter => {'Name' => 'Test'}) }

      it "should return a snapshot" do
        result.first.should be_a(Awsum::Ec2::Snapshot)
      end
    end

    describe "deleting a snapshot" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DeleteSnapshot.*SnapshotId=snap-747c911d|, :body => fixture('ec2/delete_snapshot'), :status => 200)
      end

      it "should be true" do
        ec2.delete_snapshot('snap-747c911d').should be_true
      end
    end

    describe "a snapshot" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeSnapshots.*SnapshotId.1=snap-747c911d|, :body => fixture('ec2/snapshots'), :status => 200)
      end

      let(:snapshot) { ec2.snapshot 'snap-747c911d' }

      it "should be able to delete itself" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DeleteSnapshot.*SnapshotId=snap-747c911d|, :body => fixture('ec2/snapshots'), :status => 200)

        snapshot.delete.should be_true
      end
    end
  end
end
