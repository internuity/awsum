require 'spec_helper'

functional "Instances" do
  let(:ec2) { Awsum::Ec2.new(access_key, secret_key) }

  it "should succeed" do
    image = run "retrieving an image" do
      images = ec2.images(:filter => {:architecture => 'i386', :name => '*ubuntu*', 'image-type' => 'machine', :state => 'available'})
      images[0]
    end

    instance = run "launching an instance of #{image.id}" do
      instances = image.run :instance_type => 't1.micro'
      instances[0]
    end

    wait_for instance, 'running'

    run "terminating instance #{instance.id}" do
      instance.terminate
    end

    wait_for instance, 'terminated'
  end
end
