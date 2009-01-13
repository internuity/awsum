require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

$LOAD_PATH << File.join(File.dirname(__FILE__), 'lib')
require 'awsum'

desc 'Default: run unit tests.'
task :default => [:clean, :test]

desc 'Run tests'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/test_*.rb'
  t.verbose = true
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

spec = Gem::Specification.new do |s| 
  s.name              = "awsum"
  s.version           = Awsum::VERSION
  s.author            = "Andrew Timberlake"
  s.email             = "andrew@andrewtimberlake.com"
  s.homepage          = "http://www.internuity.net/projects/awsum"
  s.platform          = Gem::Platform::RUBY
  s.summary           = "Ruby library for working with Amazon Web Services"
  s.files             = FileList["README*",
                                 "LICENSE",
                                 "Rakefile",
                                 "{lib,test}/**/*"].to_a
  s.require_path      = "lib"
  s.test_files        = FileList["test/**/test_*.rb"].to_a
  s.rubyforge_project = "awsum"
  s.has_rdoc          = true
  s.extra_rdoc_files  = FileList["README*"].to_a
  s.rdoc_options << '--line-numbers' << '--inline-source'
  s.add_development_dependency 'thoughtbot-shoulda'
  s.add_development_dependency 'mocha'
end
 
desc "Release new version"
task :release => [:test, :sync_docs, :gem] do
  require 'rubygems'
  require 'rubyforge'
  r = RubyForge.new
  r.login
  r.add_release spec.rubyforge_project,
                spec.name,
                spec.version,
                File.join("pkg", "#{spec.name}-#{spec.version}.gem")
end

desc "Generate a gemspec file for GitHub"
task :gemspec do
  File.open("#{spec.name}.gemspec", 'w') do |f|
    f.write spec.to_ruby
  end
end
