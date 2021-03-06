require File.join(File.dirname(__FILE__), '../spec_helper')

functional "Instances" do
  let(:ec2) { Awsum::Ec2.new(access_key, secret_key) }

  it "should succeed" do
    image = run "retrieving an image" do
      images = ec2.images(:filter => {:architecture => 'i386', :name => '*ubuntu*', 'image-type' => 'machine', :state => 'available'})
      images[0]
    end

    instance = run "launching an instance of #{image.id}" do
      instances = image.run :instance_type => 't1.micro', :tags => {'Name' => 'awsum.test'}
      instances[0]
    end

    wait_for instance, 'running'

    volume = run "attaching a volume to instance #{instance.id}" do
      instance.create_volume(5, :device => '/dev/sdh', :tags => {'Name' => 'awsum.test'})
    end
    wait_for volume, 'in-use'

    snapshot = run "taking a snapshot of volume #{volume.id}" do
      volume.create_snapshot :tags => {'Name' => 'awsum.test'}
    end
    wait_for snapshot, 'completed'

    run "deleting snapshot #{snapshot.id}" do
      snapshot.delete
    end

    run "detaching volue #{volume.id}" do
      volume.detach
    end
    wait_for volume, 'available'

    run "deleting volue #{volume.id}" do
      volume.delete
    end

    run "terminating instance #{instance.id}" do
      instance.terminate
    end
  end
end
