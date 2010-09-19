require 'spec_helper'

module Awsum
  describe Ec2 do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }

    describe "creating a volume" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=CreateVolume.*AvailabilityZone=us-east-1b.*Size=10|, :body => fixture('ec2/create_volume'), :status => 200)
      end

      let(:result) { ec2.create_volume 'us-east-1b', :size => 10 }

      it "should return a volume" do
        result.should be_a(Awsum::Ec2::Volume)
      end
    end

    describe "retrieving a list of volumes" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeVolumes|, :body => fixture('ec2/volumes'), :status => 200)
      end

      let(:result) { ec2.volumes }

      it "should return an array of volumes" do
        result.first.should be_a(Awsum::Ec2::Volume)
      end
    end

    describe "retrieving a volume by id" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeVolumes.*VolumeId.1=vol-44d6322d|, :body => fixture('ec2/volumes'), :status => 200)
      end

      let(:result) { ec2.volume 'vol-44d6322d' }

      it "should return a volume" do
        result.should be_a(Awsum::Ec2::Volume)
      end
    end

    describe "attaching a volume" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AttachVolume.*Device=%2Fdev%2Fsdb.*InstanceId=i-3f1cc856.*VolumeId=vol-44d6322d|, :body => fixture('ec2/attach_volume'), :status => 200)
      end

      it "should return true" do
        ec2.attach_volume('vol-44d6322d', 'i-3f1cc856', '/dev/sdb').should be_true
      end
    end

    describe "detaching a volume" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DetachVolume.*VolumeId=vol-44d6322d|, :body => fixture('ec2/detach_volume'), :status => 200)
      end

      it "should return true" do
        ec2.detach_volume('vol-44d6322d').should be_true
      end
    end

    describe "deleting a volume" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DeleteVolume.*VolumeId=vol-44d6322d|, :body => fixture('ec2/delete_volume'), :status => 200)
      end

      it "should return true" do
        ec2.delete_volume('vol-44d6322d').should be_true
      end
    end

    describe "a volume" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeVolumes.*VolumeId.1=vol-44d6322d|, :body => fixture('ec2/volumes'), :status => 200)
      end

      let(:volume) { ec2.volume 'vol-44d6322d' }

      it "should be able to detach itself" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DetachVolume.*VolumeId=vol-44d6322d|, :body => fixture('ec2/detach_volume'), :status => 200)

        volume.detach.should be_true
      end

      it "should be able to delete itself" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DeleteVolume.*VolumeId=vol-44d6322d|, :body => fixture('ec2/delete_volume'), :status => 200)

        volume.delete.should be_true
      end

      it "should be able to create a snapshot of itself" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=CreateSnapshot.*VolumeId=vol-44d6322d|, :body => fixture('ec2/create_snapshot'), :status => 200)

        volume.create_snapshot
      end

      it "should be able list it's snapshots" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeSnapshots|, :body => fixture('ec2/snapshots'), :status => 200)

        volume.snapshots.first.should be_a(Awsum::Ec2::Snapshot)
      end
    end
  end
end
