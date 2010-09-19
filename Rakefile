require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'rake/rdoctask'
require 'rake/testtask'

$LOAD_PATH.unshift('lib')
require 'awsum'

begin
  require 'jeweler'

  Jeweler::Tasks.new do |gem|
    gem.name     = 'awsum'
    gem.summary  = 'A library for working with Amazon Web Services in the most natural rubyish way'
    gem.email    = 'andrew@andrewtimberlake.com'
    gem.homepage = 'http://andrewtimberlake.com/projects/awsum'
    gem.authors  = ['Andrew Timberlake']
    gem.version  = Awsum::VERSION

    #gem.add_dependency
    gem.add_development_dependency('rspec', '>= 2.0.0.beta.22')
  end

  Jeweler::GemcutterTasks.new

  task :default => :spec
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

desc 'Run code coverage'
task :coverage do |t|
  puts `rcov -T #{Dir.glob('test/**/test_*.rb').join(' ')}`
end

desc 'Start an IRB session with all necessary files required.'
task :shell do |t|
  chdir File.dirname(__FILE__)
  exec 'irb -I lib/ -I lib/awsum -r rubygems -r awsum'
end

desc 'Generate documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.title    = 'AWSum'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Clean up files.'
task :clean do |t|
  FileUtils.rm_rf "doc"
  FileUtils.rm_rf "tmp"
  FileUtils.rm_rf "pkg"
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new do |t|
  t.pattern = "./spec/lib/**/*_spec.rb"
end

namespace :spec do
  desc "Run RSpec integration code examples (LIVE runs against Amazon AWS)"
  RSpec::Core::RakeTask.new(:integration) do |t|
    t.pattern = "./spec/functional/**/*_spec.rb"
  end
end
