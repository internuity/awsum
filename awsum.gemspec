# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{awsum}
  s.version = "0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Andrew Timberlake"]
  s.date = %q{2009-01-15}
  s.email = %q{andrew@andrewtimberlake.com}
  s.extra_rdoc_files = ["README.rdoc"]
  s.files = ["README.rdoc", "LICENSE", "Rakefile", "lib/requestable.rb", "lib/support.rb", "lib/ec2", "lib/ec2/instance.rb", "lib/ec2/image.rb", "lib/ec2/volume.rb", "lib/ec2/snapshot.rb", "lib/ec2/ec2.rb", "lib/awsum.rb", "lib/parser.rb", "test/units", "test/units/ec2", "test/units/ec2/test_image.rb", "test/units/ec2/test_ec2.rb", "test/units/ec2/test_snapshot.rb", "test/units/ec2/test_instance.rb", "test/units/ec2/test_volume.rb", "test/units/test_awsum.rb", "test/helper.rb", "test/dump.rb", "test/fixtures", "test/fixtures/ec2", "test/fixtures/ec2/instances.xml", "test/fixtures/ec2/instance.xml", "test/fixtures/ec2/attach_volume.xml", "test/fixtures/ec2/create_snapshot.xml", "test/fixtures/ec2/available_volume.xml", "test/fixtures/ec2/detach_volume.xml", "test/fixtures/ec2/create_volume.xml", "test/fixtures/ec2/delete_snapshot.xml", "test/fixtures/ec2/volumes.xml", "test/fixtures/ec2/images.xml", "test/fixtures/ec2/delete_volume.xml", "test/fixtures/ec2/image.xml", "test/fixtures/ec2/run_instances.xml", "test/fixtures/ec2/terminate_instances.xml", "test/fixtures/ec2/snapshots.xml", "test/fixtures/errors", "test/fixtures/errors/invalid_parameter_value.xml"]
  s.has_rdoc = true
  s.homepage = %q{http://www.internuity.net/projects/awsum}
  s.rdoc_options = ["--line-numbers", "--inline-source"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{awsum}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{Ruby library for working with Amazon Web Services}
  s.test_files = ["test/units/ec2/test_image.rb", "test/units/ec2/test_ec2.rb", "test/units/ec2/test_snapshot.rb", "test/units/ec2/test_instance.rb", "test/units/ec2/test_volume.rb", "test/units/test_awsum.rb", "test/fixtures/ec2/instances.xml", "test/fixtures/ec2/instance.xml", "test/fixtures/ec2/attach_volume.xml", "test/fixtures/ec2/create_snapshot.xml", "test/fixtures/ec2/available_volume.xml", "test/fixtures/ec2/detach_volume.xml", "test/fixtures/ec2/create_volume.xml", "test/fixtures/ec2/delete_snapshot.xml", "test/fixtures/ec2/volumes.xml", "test/fixtures/ec2/images.xml", "test/fixtures/ec2/delete_volume.xml", "test/fixtures/ec2/image.xml", "test/fixtures/ec2/run_instances.xml", "test/fixtures/ec2/terminate_instances.xml", "test/fixtures/ec2/snapshots.xml", "test/fixtures/errors/invalid_parameter_value.xml"]

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
