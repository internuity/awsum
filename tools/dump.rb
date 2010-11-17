#!/usr/bin/env ruby
require 'rubygems'

ROOT = File.join(File.dirname(__FILE__), '..')

$LOAD_PATH << File.join(ROOT, 'lib')
require 'awsum/ec2'
require 'awsum/s3'

#Dumps the raw result of a call to the Awsum library
# Usage ruby dump.rb -a <access key> -s <secret key> -c <command to call>
#
# Awsum::Ec2 is available as ec2
# Awsum::S3 is available as s3
#
# Exampe
# ruby dump.rb -a ABC -s XYZ -c "ec2.images"

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

ENV['DEBUG'] = 'true'

ec2 = Awsum::Ec2.new(access_key, secret_key)
s3 = Awsum::S3.new(access_key, secret_key)


module Awsum
  module Requestable
    alias_method :old_handle_response, :handle_response
    def handle_response(response, &block)
      puts "block given" if block_given?
      puts response.body
      old_handle_response(response, &block)
    end
  end
end

begin
  eval(command)
rescue Awsum::Error => e
  puts "ERROR: #{e.inspect}"
end
