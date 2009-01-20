require 'cgi'
require 'base64'
require 'openssl'
require 'ec2/address'
require 'ec2/availability_zone'
require 'ec2/image'
require 'ec2/instance'
require 'ec2/snapshot'
require 'ec2/region'
require 'ec2/volume'

module Awsum
  #--
  #TODO: Write overall class documentation with usage examples
  class Ec2
    include Awsum::Requestable

    def initialize(access_key, secret_key)
      @access_key = access_key
      @secret_key = secret_key
    end

    # Retrieve a list of available Images
    #
    # Options:
    # * <tt>:image_ids</tt> - array of Image id's, default: []
    # * <tt>:owners</tt> - array of owner id's, default: []
    # * <tt>:executable_by</tt> - array of user id's who have executable permission, #   default: []
    def images(options = {})
      options = {:image_ids => [], :owners => [], :executable_by => []}.merge(options)
      action = 'DescribeImages'
      params = {
          'Action' => action,
        }
      #Add options
      params.merge!(array_to_params(options[:image_ids], "ImageId"))
      params.merge!(array_to_params(options[:owners], "Owner"))
      params.merge!(array_to_params(options[:executable_by], "ExecutableBy"))

      response = send_request(params)
      parser = Awsum::Ec2::ImageParser.new(self)
      parser.parse(response.body)
    end

    # Retrieve a single Image
    def image(image_id)
      images(:image_ids => [image_id])[0]
    end

    # Launch an ec2 Instance
    #
    # Options:
    # * <tt>:min</tt> - The minimum number of instances to launch. Default: 1
    # * <tt>:max</tt> - The maximum number of instances to launch. Default: 1
    # * <tt>:key_name</tt> - The name of the key pair with which to launch instances
    # * <tt>:security_groups</tt> - The names of security groups to associate launched instances with
    # * <tt>:user_data</tt> - User data made available to instances (Note: Must be 16K or less, will be base64 encoded by Awsum)
    # * <tt>:instance_type</tt> - The size of the instances to launch, can be one of [m1.small, m1.large, m1.xlarge, c1.medium, c1.xlarge], default is m1.small
    # * <tt>:availability_zone</tt> - The name of the availability zone to launch this Instance in
    # * <tt>:kernel_id</tt> - The ID of the kernel with which to launch instances
    # * <tt>:ramdisk_id</tt> - The ID of the RAM disk with which to launch instances
    # * <tt>:block_device_map</tt> - A 'hash' of mappings. E.g. {'instancestore0' => 'sdb'}
    def run_instances(image_id, options = {})
      options = {:min => 1, :max => 1}.merge(options)
      action = 'RunInstances'
      params = {
        'Action'                     => action,
        'ImageId'                    => image_id,
        'MinCount'                   => options[:min],
        'MaxCount'                   => options[:max],
        'KeyName'                    => options[:key_name],
        'UserData'                   => options[:user_data].nil? ? nil : Base64::encode64(options[:user_data]).gsub(/\n/, ''),
        'InstanceType'               => options[:instance_type],
        'Placement.AvailabilityZone' => options[:availability_zone],
        'KernelId'                   => options[:kernel_id],
        'RamdiskId'                  => options[:ramdisk_id]
      }
      if options[:block_device_map].respond_to?(:keys)
        map = options[:block_device_map]
        map.keys.each_with_index do |key, i|
          params["BlockDeviceMapping.#{i+1}.VirtualName"] = key
          params["BlockDeviceMapping.#{i+1}.DeviceName"] = map[key]
        end
      else
        raise ArgumentError.new("options[:block_device_map] - must be a key => value map") unless options[:block_device_map].nil?
      end
      params.merge!(array_to_params(options[:security_groups], "SecurityGroup"))

      response = send_request(params)
      parser = Awsum::Ec2::InstanceParser.new(self)
      parser.parse(response.body)
    end
    alias_method :launch_instances, :run_instances

    #Retrieve the information on a number of Instance(s)
    def instances(*instance_ids)
      action = 'DescribeInstances'
      params = {
        'Action' => action
      }
      params.merge!(array_to_params(instance_ids, 'InstanceId'))

      response = send_request(params)
      parser = Awsum::Ec2::InstanceParser.new(self)
      parser.parse(response.body)
    end

    #Retrieve the information on a single Instance
    def instance(instance_id)
      instances([instance_id])[0]
    end

    # Retrieves the currently running Instance
    # This should only be run on a running EC2 instance
    def me
      require 'open-uri'
      begin
        instance_id = open('http://169.254.169.254/latest/meta-data/instance-id').read
        instance instance_id
      rescue OpenURI::HTTPError => e
        nil
      end
    end

    # Retreives the user-data supplied when starting the currently running Instance
    # This should only be run on a running EC2 instance
    def user_data
      require 'open-uri'
      begin
        open('http://169.254.169.254/latest/user-data').read
      rescue OpenURI::HTTPError => e
        nil
      end
    end

    # Terminates the Instance(s)
    #
    # Returns true if the terminations succeeds, false otherwise
    def terminate_instances(*instance_ids)
      action = 'TerminateInstances'
      params = {
        'Action' => action
      }
      params.merge!(array_to_params(instance_ids, 'InstanceId'))

      response = send_request(params)
      response.is_a?(Net::HTTPSuccess)
    end

    #Retrieve the information on a number of Volume(s)
    def volumes(*volume_ids)
      action = 'DescribeVolumes'
      params = {
        'Action' => action
      }
      params.merge!(array_to_params(volume_ids, 'VolumeId'))

      response = send_request(params)
      parser = Awsum::Ec2::VolumeParser.new(self)
      parser.parse(response.body)
    end

    # Retreive information on a Volume
    def volume(volume_id)
      volumes(volume_id)[0]
    end

    # Create a new volume
    #
    # Options:
    # * <tt>:size</tt> - The size of the volume to be created (in GB) (<b>NOTE:</b> Required if you are not creating from a snapshot)
    # * <tt>:snapshot_id</tt> - The snapshot id from which to create the volume
    #
    def create_volume(availability_zone, options = {})
      raise ArgumentError.new('You must specify a size if not creating a volume from a snapshot') if options[:snapshot_id].blank? && options[:size].blank?

      action = 'CreateVolume'
      params = {
        'Action'           => action,
        'AvailabilityZone' => availability_zone
      }
      params['Size'] = options[:size] unless options[:size].blank?
      params['SnapshotId'] = options[:snapshot_id] unless options[:snapshot_id].blank?

      response = send_request(params)
      parser = Awsum::Ec2::VolumeParser.new(self)
      parser.parse(response.body)[0]
    end

    # Attach a volume to an instance
    def attach_volume(volume_id, instance_id, device = '/dev/sdh')
      action = 'AttachVolume'
      params = {
        'Action'     => action,
        'VolumeId'   => volume_id,
        'InstanceId' => instance_id,
        'Device'     => device
      }

      response = send_request(params)
      response.is_a?(Net::HTTPSuccess)
    end

    # Detach a volume from an instance
    #
    # Options
    # * <tt>:instance_id</tt> - The ID of the instance from which the volume will detach
    # * <tt>:device</tt> - The device name
    # * <tt>:force</tt> - Whether to force the detachment. <b>NOTE:</b> If forced you may have data corruption issues.
    def detach_volume(volume_id, options = {})
      action = 'DetachVolume'
      params = {
        'Action'     => action,
        'VolumeId'   => volume_id
      }
      params['InstanceId'] = options[:instance_id] unless options[:instance_id].blank?
      params['Device'] = options[:device] unless options[:device].blank?
      params['Force'] = options[:force] unless options[:force].blank?

      response = send_request(params)
      response.is_a?(Net::HTTPSuccess)
    end

    # Delete a volume
    def delete_volume(volume_id)
      action = 'DeleteVolume'
      params = {
        'Action'     => action,
        'VolumeId'   => volume_id
      }

      response = send_request(params)
      response.is_a?(Net::HTTPSuccess)
    end

    # Create a Snapshot of a Volume
    def create_snapshot(volume_id)
      action = 'CreateSnapshot'
      params = {
        'Action'   => action,
        'VolumeId' => volume_id
      }

      response = send_request(params)
      parser = Awsum::Ec2::SnapshotParser.new(self)
      parser.parse(response.body)[0]
    end

    # List Snapshot(s)
    def snapshots(*snapshot_ids)
      action = 'DescribeSnapshots'
      params = {
        'Action' => action
      }
      params.merge!(array_to_params(snapshot_ids, 'SnapshotId'))

      response = send_request(params)
      parser = Awsum::Ec2::SnapshotParser.new(self)
      parser.parse(response.body)
    end

    # Get the information about a Snapshot
    def snapshot(snapshot_id)
      snapshots(snapshot_id)[0]
    end

    # Delete a Snapshot
    def delete_snapshot(snapshot_id)
      action = 'DeleteSnapshot'
      params = {
        'Action'     => action,
        'SnapshotId' => snapshot_id
      }

      response = send_request(params)
      response.is_a?(Net::HTTPSuccess)
    end

    # List all AvailabilityZone(s)
    def availability_zones(*zone_names)
      action = 'DescribeAvailabilityZones'
      params = {
        'Action' => action
      }
      params.merge!(array_to_params(zone_names, 'ZoneName'))

      response = send_request(params)
      parser = Awsum::Ec2::AvailabilityZoneParser.new(self)
      parser.parse(response.body)
    end

    # List all Region(s)
    def regions(*region_names)
      action = 'DescribeRegions'
      params = {
        'Action' => action
      }
      params.merge!(array_to_params(region_names, 'Region'))

      response = send_request(params)
      parser = Awsum::Ec2::RegionParser.new(self)
      parser.parse(response.body)
    end

    # List a Region
    def region(region_name)
      regions(region_name)[0]
    end

    # List Addresses
    def addresses(*public_ips)
      action = 'DescribeAddresses'
      params = {
        'Action' => action
      }
      params.merge!(array_to_params(public_ips, 'PublicIp'))

      response = send_request(params)
      parser = Awsum::Ec2::AddressParser.new(self)
      parser.parse(response.body)
    end

    # Get the Address with a specific public ip
    def address(public_ip)
      addresses(public_ip)[0]
    end

    # Allocate Address
    #
    # Will aquire an elastic ip address for use with your account
    def allocate_address
      action = 'AllocateAddress'
      params = {
        'Action' => action
      }

      response = send_request(params)
      parser = Awsum::Ec2::AddressParser.new(self)
      parser.parse(response.body)[0]
    end

    # Associate Address
    #
    # Will link an allocated elastic ip address to an Instance
    #
    # <b>NOTE:</b> If the ip address is already associated with another instance, it will be associated with the new instance.
    #
    # You can run this command more than once and it will not return an error.
    def associate_address(instance_id, public_ip)
      action = 'AssociateAddress'
      params = {
        'Action'     => action,
        'InstanceId' => instance_id,
        'PublicIp'   => public_ip
      }

      response = send_request(params)
      response.is_a?(Net::HTTPSuccess)
    end

    # Disassociate Address
    #
    # Will disassociate an allocated elastic ip address from the Instance it's allocated to
    #
    # <b>NOTE:</b> You can run this command more than once and it will not return an error.
    def disassociate_address(public_ip)
      action = 'DisassociateAddress'
      params = {
        'Action'     => action,
        'PublicIp'   => public_ip
      }

      response = send_request(params)
      response.is_a?(Net::HTTPSuccess)
    end

    # Releasees an associated Address
    #
    # <b>NOTE:</b> This is not a direct call to the Amazon web service. This is a safe operation that will first check to see if the address is allocated to an instance and fail if it is
    def release_address(public_ip)
      address = address(public_ip)

      if address.instance_id.nil?
        action = 'ReleaseAddress'
        params = {
          'Action'   => action,
          'PublicIp' => public_ip
        }

        response = send_request(params)
        response.is_a?(Net::HTTPSuccess)
      else
        raise 'Address is currently allocated' #FIXME: Add a proper Awsum error here
      end
    end

    # Releasees an associated Address
    #
    # <b>NOTE:</b> This will disassociate an address automatically if it is associated with an instance
    def release_address!(public_ip)
      action = 'ReleaseAddress'
      params = {
        'Action'   => action,
        'PublicIp' => public_ip
      }

      response = send_request(params)
      response.is_a?(Net::HTTPSuccess)
    end

#private
    #The host to make all requests against
    def host
      @host ||= 'ec2.amazonaws.com'
    end

    def host=(host)
      @host = host
    end
  end
end
