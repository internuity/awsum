# AWSum is a library facilitating access to Amazon's web services in (hopefully)
# a very object-oriented, ruby way.
#
# Author:: Andrew Timberlake
# Copyright:: Copyright (c) 2009 Internuity Ltd
# Licence:: MIT License (http://www.opensource.org/licenses/mit-license.php)
#

require 'support'
require 'requestable'
require 'parser'
require 'ec2/ec2'

module Awsum
  
  VERSION = "0.1"

  API_VERSION = '2008-12-01'
  SIGNATURE_VERSION = 2
end


