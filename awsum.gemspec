# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{awsum}
  s.version = "0.3"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew Timberlake"]
  s.date = %q{2009-03-05}
  s.email = %q{andrew@andrewtimberlake.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "LICENSE", "Rakefile", "lib/error.rb", "lib/parser.rb", "lib/support.rb", "lib/ec2", "lib/ec2/snapshot.rb", "lib/ec2/availability_zone.rb", "lib/ec2/security_group.rb", "lib/ec2/volume.rb", "lib/ec2/instance.rb", "lib/ec2/region.rb", "lib/ec2/address.rb", "lib/ec2/ec2.rb", "lib/ec2/image.rb", "lib/ec2/keypair.rb", "lib/requestable.rb", "lib/s3", "lib/s3/headers.rb", "lib/s3/bucket.rb", "lib/s3/object.rb", "lib/s3/s3.rb", "lib/awsum.rb", "lib/net_fix.rb", "test/fixtures", "test/fixtures/errors", "test/fixtures/errors/invalid_parameter_value.xml", "test/fixtures/ec2", "test/fixtures/ec2/terminate_instances.xml", "test/fixtures/ec2/create_snapshot.xml", "test/fixtures/ec2/delete_security_group.xml", "test/fixtures/ec2/delete_snapshot.xml", "test/fixtures/ec2/internal_error.xml", "test/fixtures/ec2/instance.xml", "test/fixtures/ec2/revoke_ip_access.xml", "test/fixtures/ec2/create_volume.xml", "test/fixtures/ec2/disassociate_address.xml", "test/fixtures/ec2/available_volume.xml", "test/fixtures/ec2/snapshots.xml", "test/fixtures/ec2/register_image.xml", "test/fixtures/ec2/deregister_image.xml", "test/fixtures/ec2/volumes.xml", "test/fixtures/ec2/invalid_amiid_error.xml", "test/fixtures/ec2/regions.xml", "test/fixtures/ec2/create_security_group.xml", "test/fixtures/ec2/authorize_owner_group_access_error.xml", "test/fixtures/ec2/run_instances.xml", "test/fixtures/ec2/revoke_owner_group_access.xml", "test/fixtures/ec2/invalid_request_error.xml", "test/fixtures/ec2/attach_volume.xml", "test/fixtures/ec2/images.xml", "test/fixtures/ec2/delete_key_pair.xml", "test/fixtures/ec2/authorize_owner_group_access.xml", "test/fixtures/ec2/availability_zones.xml", "test/fixtures/ec2/authorize_ip_access.xml", "test/fixtures/ec2/create_key_pair.xml", "test/fixtures/ec2/instances.xml", "test/fixtures/ec2/image.xml", "test/fixtures/ec2/key_pairs.xml", "test/fixtures/ec2/addresses.xml", "test/fixtures/ec2/allocate_address.xml", "test/fixtures/ec2/unassociated_address.xml", "test/fixtures/ec2/security_groups.xml", "test/fixtures/ec2/detach_volume.xml", "test/fixtures/ec2/delete_volume.xml", "test/fixtures/ec2/associate_address.xml", "test/fixtures/ec2/release_address.xml", "test/fixtures/s3", "test/fixtures/s3/invalid_request_signature.xml", "test/fixtures/s3/copy_failure.xml", "test/fixtures/s3/buckets.xml", "test/fixtures/s3/keys.xml", "test/helper.rb", "test/dump.rb", "test/units", "test/units/test_error.rb", "test/units/ec2", "test/units/ec2/test_instance.rb", "test/units/ec2/test_snapshot.rb", "test/units/ec2/test_volume.rb", "test/units/ec2/test_image.rb", "test/units/ec2/test_regions.rb", "test/units/ec2/test_keypair.rb", "test/units/ec2/test_security_group.rb", "test/units/ec2/test_addresses.rb", "test/units/ec2/test_ec2.rb", "test/units/s3", "test/units/s3/test_bucket.rb", "test/units/s3/test_object.rb", "test/units/s3/test_s3.rb", "test/units/test_requestable.rb", "test/units/test_awsum.rb", "test/work_out_string_to_sign.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://www.internuity.net/projects/awsum}
  s.rdoc_options = ["--line-numbers", "--inline-source"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{awsum}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Ruby library for working with Amazon Web Services}
  s.test_files = ["test/units/test_error.rb", "test/units/ec2/test_instance.rb", "test/units/ec2/test_snapshot.rb", "test/units/ec2/test_volume.rb", "test/units/ec2/test_image.rb", "test/units/ec2/test_regions.rb", "test/units/ec2/test_keypair.rb", "test/units/ec2/test_security_group.rb", "test/units/ec2/test_addresses.rb", "test/units/ec2/test_ec2.rb", "test/units/s3/test_bucket.rb", "test/units/s3/test_object.rb", "test/units/s3/test_s3.rb", "test/units/test_requestable.rb", "test/units/test_awsum.rb", "test/fixtures/errors/invalid_parameter_value.xml", "test/fixtures/ec2/terminate_instances.xml", "test/fixtures/ec2/create_snapshot.xml", "test/fixtures/ec2/delete_security_group.xml", "test/fixtures/ec2/delete_snapshot.xml", "test/fixtures/ec2/internal_error.xml", "test/fixtures/ec2/instance.xml", "test/fixtures/ec2/revoke_ip_access.xml", "test/fixtures/ec2/create_volume.xml", "test/fixtures/ec2/disassociate_address.xml", "test/fixtures/ec2/available_volume.xml", "test/fixtures/ec2/snapshots.xml", "test/fixtures/ec2/register_image.xml", "test/fixtures/ec2/deregister_image.xml", "test/fixtures/ec2/volumes.xml", "test/fixtures/ec2/invalid_amiid_error.xml", "test/fixtures/ec2/regions.xml", "test/fixtures/ec2/create_security_group.xml", "test/fixtures/ec2/authorize_owner_group_access_error.xml", "test/fixtures/ec2/run_instances.xml", "test/fixtures/ec2/revoke_owner_group_access.xml", "test/fixtures/ec2/invalid_request_error.xml", "test/fixtures/ec2/attach_volume.xml", "test/fixtures/ec2/images.xml", "test/fixtures/ec2/delete_key_pair.xml", "test/fixtures/ec2/authorize_owner_group_access.xml", "test/fixtures/ec2/availability_zones.xml", "test/fixtures/ec2/authorize_ip_access.xml", "test/fixtures/ec2/create_key_pair.xml", "test/fixtures/ec2/instances.xml", "test/fixtures/ec2/image.xml", "test/fixtures/ec2/key_pairs.xml", "test/fixtures/ec2/addresses.xml", "test/fixtures/ec2/allocate_address.xml", "test/fixtures/ec2/unassociated_address.xml", "test/fixtures/ec2/security_groups.xml", "test/fixtures/ec2/detach_volume.xml", "test/fixtures/ec2/delete_volume.xml", "test/fixtures/ec2/associate_address.xml", "test/fixtures/ec2/release_address.xml", "test/fixtures/s3/invalid_request_signature.xml", "test/fixtures/s3/copy_failure.xml", "test/fixtures/s3/buckets.xml", "test/fixtures/s3/keys.xml"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_development_dependency(%q<mocha>, [">= 0"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<mocha>, [">= 0"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<mocha>, [">= 0"])
  end
end
