require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'

begin
  require 'ruby-debug'
rescue LoadError
  puts "ruby-debug not loaded"
end

ROOT = File.join(File.dirname(__FILE__), '..')

$LOAD_PATH << File.join(ROOT, 'lib')
$LOAD_PATH << File.join(ROOT, 'lib', 'awsum')

require File.join(ROOT, 'lib', 'awsum.rb')

def load_fixture(fixture_name)
  File.read File.join(File.dirname(__FILE__), "fixtures/#{fixture_name}.xml")
end
