require 'rubygems'

ROOT = File.join(File.dirname(__FILE__), '..')

$LOAD_PATH << File.join(ROOT, 'lib')
$LOAD_PATH << File.join(ROOT, 'lib', 'awsum')
require File.join(ROOT, 'lib', 'awsum.rb')

#Dumps the raw result of a call to the Awsum library
# Usage ruby dump.rb -a <access key> -s <secret key> -c <command to call>
#
# Awsum::Ec2 is available as ec2
#
# Exampe
# ruby dump.rb -a ABC -s XYZ -c "ec2.images"

module Awsum
  class Parser
    def parse(xml_text)
      puts xml_text
    end
  end
end

#Parse command line
access_key = nil
secret_key = nil
command = nil
ARGV.each_with_index do |arg, i|
  case arg
    when '-a'
      access_key = ARGV[i+1]
    when '-s'
      secret_key = ARGV[i+1]
    when '-c'
      command = ARGV[i+1]
  end
end

ec2 = Awsum::Ec2.new(access_key, secret_key)
eval command