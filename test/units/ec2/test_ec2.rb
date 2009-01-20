require File.expand_path('../../helper', File.dirname(__FILE__))

class ImagesTest < Test::Unit::TestCase
  def setup
    @ec2 = Awsum::Ec2.new('abc', 'xyz')
  end

  context "Images: " do
    context "retrieving a list of images" do
      setup {
        xml = load_fixture('ec2/images')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.images
      }

      should "return an array of images" do
        assert @result.is_a?(Array)
        assert_equal Awsum::Ec2::Image, @result[0].class
      end
    end

    context "retrieving a single image by id" do
      setup {
        xml = load_fixture('ec2/image')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.image 'ari-f9c22690'
      }

      should "return a single image" do
        assert_equal Awsum::Ec2::Image, @result.class
      end
    end

    context "an image" do
      setup {
        xml = load_fixture('ec2/image')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @image = @ec2.image 'ari-f9c22690'
      }

      should "be able to create an instance" do
        xml = load_fixture('ec2/instance')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        instances = @image.run
        assert_equal Awsum::Ec2::Instance, instances[0].class
      end
    end
  end

  context "Instances: " do
    context "Block device map" do
      setup {
        xml = load_fixture('ec2/run_instances')
        response = stub('Http Response', :body => xml)
        http = mock('HTTP', :use_ssl= => nil, :verify_mode= => nil)
        http.expects(:send_request).with{|method, uri, data, headers| @uri = uri}.returns(response)
        Net::HTTP.expects(:new).returns(http)
        @ec2.run_instances('ari-ABCDEF123', :block_device_map => {'instancestore0' => 'sdb'})
      }

      should "generate the correct parameter names" do
        assert_match /BlockDeviceMapping\.1\.VirtualName=instancestore0/, @uri
        assert_match /BlockDeviceMapping\.1\.DeviceName=sdb/, @uri
      end
    end

    context "Running an instance" do
      setup {
        xml = load_fixture('ec2/run_instances')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.run_instances 'ari-f9c22690'
      }

      should "return an array of instances" do
        assert @result.is_a?(Array)
        assert_equal Awsum::Ec2::Instance, @result[0].class
      end
    end

    context "retrieving a list of instances" do
      setup {
        xml = load_fixture('ec2/instances')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.instances
      }

      should "return an array of instances" do
        assert @result.is_a?(Array)
        assert_equal Awsum::Ec2::Instance, @result[0].class
      end
    end

    context "retrieving a single instance by id" do
      setup {
        xml = load_fixture('ec2/instance')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.instance 'i-3f1cc856'
      }

      should "return a single instance" do
        assert_equal Awsum::Ec2::Instance, @result.class
      end
    end

    context "terminating instances" do
      setup {
        xml = load_fixture('ec2/terminate_instances')
        response = stub('Http Response', :body => xml)
        response.expects(:is_a?).returns(true)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.terminate_instances 'i-3f1cc856'
      }

      should "return true" do
        assert @result
      end
    end

    context "an instance" do
      setup {
        xml = load_fixture('ec2/instance')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @instance = @ec2.instance 'i-3f1cc856'
      }

      should "be able to terminate" do
        xml = load_fixture('ec2/terminate_instances')
        response = stub('Http Response', :body => xml)
        response.expects(:is_a?).returns(true)
        @ec2.expects(:send_request).returns(response)

        assert @instance.terminate
      end

      should "be able to list it's volumes" do
        xml = load_fixture('ec2/volumes')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        assert @instance.volumes.is_a?(Array)
      end

      should "be able to attach a volumes" do
        xml = load_fixture('ec2/volumes')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        volume = @ec2.volumes[0]

        xml = load_fixture('ec2/attach_volume')
        response = stub('Http Response', :body => xml)
        response.expects(:is_a?).returns(true)
        @ec2.expects(:send_request).returns(response)

        assert @instance.attach(volume)
      end

      should "be able to create a volume" do
        requests = sequence('requests')

        xml = load_fixture('ec2/create_volume')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response).in_sequence(requests)

        xml = load_fixture('ec2/available_volume')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response).in_sequence(requests)

        xml = load_fixture('ec2/attach_volume')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response).in_sequence(requests)

        volume = @instance.create_volume(10)
        assert_equal Awsum::Ec2::Volume, volume.class
      end
    end
    
    context "On a running EC2 instance" do
      should "be able to obtain an Instance representing the currently running machine" do
        xml = load_fixture('ec2/instance')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        io = mock('OpenURI', :read => 'i-3f1cc856')
        @ec2.expects(:open).returns(io)

        instance = @ec2.me
        assert_equal Awsum::Ec2::Instance, instance.class
      end

      should "return nil if an http error is received" do
        @ec2.expects(:open).raises(OpenURI::HTTPError.new(404, 'problem'))

        instance = @ec2.me
        assert_nil instance
      end

      should "be able to retrieve the user data" do
        io = mock('OpenURI', :read => 'This is the user data')
        @ec2.expects(:open).returns(io)

        user_data = @ec2.user_data
        assert_equal 'This is the user data', user_data
      end

      should "return nil if there is no user data" do
        @ec2.expects(:open).raises(OpenURI::HTTPError.new(404, 'problem'))

        user_data = @ec2.user_data
        assert_nil user_data
      end
    end
  end

  context "Volumes: " do
    context "Creating a volume" do
      setup {
        xml = load_fixture('ec2/create_volume')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.create_volume 'us-east-1b', :size => 10
      }

      should "return a volume" do
        assert_equal Awsum::Ec2::Volume, @result.class
      end
    end

    context "retrieving a list of volumes" do
      setup {
        xml = load_fixture('ec2/volumes')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.volumes
      }

      should "return an array of volumes" do
        assert @result.is_a?(Array)
        assert_equal Awsum::Ec2::Volume, @result[0].class
      end
    end

    context "Attaching a volume" do
      setup {
        xml = load_fixture('ec2/attach_volume')
        response = stub('Http Response', :body => xml)
        response.expects(:is_a?).returns(true)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.attach_volume 'vol-44d6322d', 'i-3f1cc856', '/dev/sdb'
      }

      should "return true" do
        assert @result
      end
    end

    context "Detaching a volume" do
      setup {
        xml = load_fixture('ec2/detach_volume')
        response = stub('Http Response', :body => xml)
        response.expects(:is_a?).returns(true)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.detach_volume 'vol-44d6322d'
      }

      should "return true" do
        assert @result
      end
    end

    context "Deleting a volume" do
      setup {
        xml = load_fixture('ec2/delete_volume')
        response = stub('Http Response', :body => xml)
        response.expects(:is_a?).returns(true)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.delete_volume 'vol-44d6322d'
      }

      should "return true" do
        assert @result
      end
    end

    context "a volume" do
      setup {
        xml = load_fixture('ec2/volumes')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @volume = @ec2.volume 'vol-44d6322d'
      }

      should "be able to detach" do
        xml = load_fixture('ec2/detach_volume')
        response = stub('Http Response', :body => xml)
        response.expects(:is_a?).returns(true)
        @ec2.expects(:send_request).returns(response)

        assert @volume.detach
      end

      should "be able to delete" do
        xml = load_fixture('ec2/delete_volume')
        response = stub('Http Response', :body => xml)
        response.expects(:is_a?).returns(true)
        @ec2.expects(:send_request).returns(response)

        assert @volume.delete
      end

      should "be able to create a snapshot" do
        xml = load_fixture('ec2/create_snapshot')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        assert @volume.create_snapshot
      end

      should "be able to list it's snapshots" do
        xml = load_fixture('ec2/snapshots')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        assert @volume.snapshots.is_a?(Array)
      end
    end
  end

  context "Snapshots: " do
    context "Creating a snapshot" do
      setup {
        xml = load_fixture('ec2/create_snapshot')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.create_snapshot 'vol-79d13510'
      }

      should "return a snapshot" do
        assert_equal Awsum::Ec2::Snapshot, @result.class
      end
    end

    context "retrieving a list of snapshots" do
      setup {
        xml = load_fixture('ec2/snapshots')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.snapshots
      }

      should "return an array of snapshots" do
        assert @result.is_a?(Array)
        assert_equal Awsum::Ec2::Snapshot, @result[0].class
      end
    end

    context "Deleting a snapshot" do
      setup {
        xml = load_fixture('ec2/delete_snapshot')
        response = stub('Http Response', :body => xml)
        response.expects(:is_a?).returns(true)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.delete_snapshot 'snap-747c911d'
      }

      should "return true" do
        assert @result
      end
    end

    context "a snapshot" do
      setup {
        xml = load_fixture('ec2/snapshots')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @snapshot = @ec2.snapshot 'snap-747c911d'
      }

      should "be able to delete" do
        xml = load_fixture('ec2/delete_snapshot')
        response = stub('Http Response', :body => xml)
        response.expects(:is_a?).returns(true)
        @ec2.expects(:send_request).returns(response)

        assert @snapshot.delete
      end
    end
  end

  context "Availability Zones: " do
    context "retrieving a list of availability zones" do
      setup {
        xml = load_fixture('ec2/availability_zones')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.availability_zones
      }

      should "return an array of availability zones" do
        assert @result.is_a?(Array)
        assert_equal Awsum::Ec2::AvailabilityZone, @result[0].class
      end
    end
  end

  context "Regions: " do
    context "retrieving a list of regions" do
      setup {
        xml = load_fixture('ec2/regions')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.regions
      }

      should "return an array of regions" do
        assert @result.is_a?(Array)
        assert_equal Awsum::Ec2::Region, @result[0].class
      end
    end

    context "a region" do
      setup {
        xml = load_fixture('ec2/regions')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @region = @ec2.region 'us-east-1'
      }

      should "be able to list availability zones" do
        xml = load_fixture('ec2/availability_zones')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        assert @region.availability_zones.is_a?(Array)
      end

      should "work in block mode" do
        xml = load_fixture('ec2/availability_zones')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        azones = nil
        @region.use do
          azones = availability_zones
        end
        assert azones.is_a?(Array)
        assert_equal Awsum::Ec2::AvailabilityZone, azones[0].class
      end

      should "pass non-region methods on to it's internal ec2 object (method missing)" do
        @ec2.expects(:run_instances).returns(true)

        assert @region.run_instances('i-123456789')
      end
    end
  end

  context "Addresses: " do
    context "retrieving a list of addresses" do
      setup {
        xml = load_fixture('ec2/addresses')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @result = @ec2.addresses
      }

      should "return an array of addresses" do
        assert @result.is_a?(Array)
        assert_equal Awsum::Ec2::Address, @result[0].class
      end
    end

    context "allocating an address" do
      setup {
        xml = load_fixture('ec2/allocate_address')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)
        
        @result = @ec2.allocate_address
      }

      should "return an Address" do
        assert_equal Awsum::Ec2::Address, @result.class
      end
    end

    context "associate an address" do
      setup {
        xml = load_fixture('ec2/associate_address')
        response = stub('Http Response', :body => xml)
        response.expects(:is_a?).returns(true)
        @ec2.expects(:send_request).returns(response)
      }

      should "succeed" do
        assert @ec2.associate_address('127.0.0.1', 'i-ABCDEF')
      end
    end

    context "disassociate an address" do
      setup {
        xml = load_fixture('ec2/disassociate_address')
        response = stub('Http Response', :body => xml)
        response.expects(:is_a?).returns(true)
        @ec2.expects(:send_request).returns(response)
      }

      should "succeed" do
        assert @ec2.disassociate_address('127.0.0.1')
      end
    end

    context "release an address" do
      setup {
        requests = sequence('requests')
        
        xml = load_fixture('ec2/unassociated_address')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response).in_sequence(requests)

        xml = load_fixture('ec2/release_address')
        response = stub('Http Response', :body => xml)
        response.expects(:is_a?).returns(true)
        @ec2.expects(:send_request).returns(response).in_sequence(requests)
      }

      should "succeed" do
        assert @ec2.release_address('127.0.0.1')
      end
    end

    context "release an associated address" do
      setup {
        xml = load_fixture('ec2/addresses')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)
      }

      should "raise an error" do
        assert_raise RuntimeError do
          @ec2.release_address('127.0.0.1')
        end
      end
    end

    context "force the release of an address" do
      setup {
        xml = load_fixture('ec2/release_address')
        response = stub('Http Response', :body => xml)
        response.expects(:is_a?).returns(true)
        @ec2.expects(:send_request).returns(response)
      }

      should "succeed" do
        assert @ec2.release_address!('127.0.0.1')
      end
    end

    context "an address" do
      setup {
        xml = load_fixture('ec2/unassociated_address')
        @response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(@response)

        @address = @ec2.address('127.0.0.1')
      }

      should "be able to associate with an instance" do
        xml = load_fixture('ec2/associate_address')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)
        response.expects(:is_a?).returns(true)

        assert @address.associate('i-123456')
      end

      should "not be able to disassociate with an instance" do
        assert_raise RuntimeError do
          @address.disassociate
        end
      end

      should "be able to release" do
        requests = sequence('requests')

        xml = load_fixture('ec2/unassociated_address')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response).in_sequence(requests)

        xml = load_fixture('ec2/release_address')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response).in_sequence(requests)
        response.expects(:is_a?).returns(true).in_sequence(requests)

        assert @address.release
      end
    end

    context "an associated address" do
      setup {
        xml = load_fixture('ec2/addresses')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        @address = @ec2.address('127.0.0.1')
      }

      should "return the instance it's associated with" do
        xml = load_fixture('ec2/instances')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)

        assert_equal Awsum::Ec2::Instance, @address.instance.class
      end

      should "not be able to associate with an instance" do
        assert_raise RuntimeError do
          @address.associate('i-ABCDEF')
        end
      end

      should "be able to disassociate from an instance" do
        xml = load_fixture('ec2/disassociate_address')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)
        response.expects(:is_a?).returns(true)

        assert @address.disassociate
      end

      should "raise an error when released" do
        assert_raise RuntimeError do
          @address.release
        end
      end

      should "be able to release when forced" do
        xml = load_fixture('ec2/release_address')
        response = stub('Http Response', :body => xml)
        @ec2.expects(:send_request).returns(response)
        response.expects(:is_a?).returns(true)

        assert @address.release!
      end
    end
  end
end
