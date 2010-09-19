require 'spec_helper'

module Awsum
  describe Ec2 do

    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }

    describe "running an instance" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=RunInstances.*ImageId=ari-f9c22690|, :body => fixture('ec2/run_instances'), :status => 200)
      end

      let(:result) { ec2.run_instances 'ari-f9c22690' }

      it "should return an array of instances" do
        result.first.should be_a(Awsum::Ec2::Instance)
      end
    end

    describe "retrieving a list of instances" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeInstances|, :body => fixture('ec2/run_instances'), :status => 200)
      end

      let(:result) { ec2.instances }

      it "should return an array of instances" do
        result.first.should be_a(Awsum::Ec2::Instance)
      end
    end

    describe "retrieving a single instance" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeInstances.*InstanceId.1=i-3f1cc856|, :body => fixture('ec2/instance'), :status => 200)
      end

      let(:result) { ec2.instance 'i-3f1cc856' }

      it "should return an instance" do
        result.should be_a(Awsum::Ec2::Instance)
      end
    end

    describe "terminating an instance" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=TerminateInstances.*InstanceId.1=i-3f1cc856|, :body => fixture('ec2/terminate_instances'), :status => 200)
      end

      it "should return an instance" do
        ec2.terminate_instances('i-3f1cc856').should be_true
      end
    end

    describe "an instance" do
      before do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeInstances.*InstanceId.1=i-3f1cc856|, :body => fixture('ec2/instance'), :status => 200)
      end

      let(:instance) { ec2.instance 'i-3f1cc856' }

      it "should be able to terminate" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=TerminateInstances.*InstanceId.1=i-3f1cc856|, :body => fixture('ec2/terminate_instances'), :status => 200)

        instance.terminate.should be_true
      end

      it "should be able to list it's volumes" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeVolumes|, :body => fixture('ec2/volumes'), :status => 200)

        volumes = instance.volumes
        volumes.first.should be_a(Awsum::Ec2::Volume)
        volumes.first.instance_id.should == instance.id
      end

      it "should be able to attach a volume" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeVolumes|, :body => fixture('ec2/volumes'), :status => 200)

        volume = ec2.volumes.last

        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AttachVolume.*InstanceId=i-3f1cc856.*VolumeId=vol-44d6322d|, :body => fixture('ec2/attach_volume'), :status => 200)

        instance.attach(volume).should be_true
      end

      it "should be able to create a volume" do
        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=CreateVolume|, :body => fixture('ec2/create_volume'), :status => 200)

        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeVolumes.*VolumeId.1=vol-44d6322d|, :body => fixture('ec2/available_volume'), :status => 200)

        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=AttachVolume.*InstanceId=i-3f1cc856.*VolumeId=vol-44d6322d|, :body => fixture('ec2/attach_volume'), :status => 200)

        instance.create_volume(10)
      end
    end

    describe "on a running instance" do
      it "should be able to retrieve an instance of itself" do
        FakeWeb.register_uri(:get, 'http://169.254.169.254/latest/meta-data/instance-id', :body => 'i-3f1cc856', :status => 200)

        FakeWeb.register_uri(:get, %r|https://ec2\.amazonaws\.com/?.*Action=DescribeInstances.*InstanceId.1=i-3f1cc856|, :body => fixture('ec2/instance'), :status => 200)

        ec2.me.should be_a(Awsum::Ec2::Instance)
      end

      it "should return nil if not a running instance" do
        FakeWeb.register_uri(:get, 'http://169.254.169.254/latest/meta-data/instance-id', :body => '', :status => 404)

        ec2.me.should be_nil
      end

      it "should be able to retrieve the user data" do
        FakeWeb.register_uri(:get, 'http://169.254.169.254/latest/user-data', :body => 'This is the user data', :status => 200)

        ec2.user_data.should == 'This is the user data'
      end

      it "should return nil if there's no user data" do
        FakeWeb.register_uri(:get, 'http://169.254.169.254/latest/user-data', :body => '', :status => 404)

        ec2.user_data.should be_nil
      end
    end
  end
end
