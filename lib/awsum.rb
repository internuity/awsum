# AWSum is a library facilitating access to Amazon's web services in (hopefully)
# a very object-oriented, ruby way.
#
# Author:: Andrew Timberlake
# Copyright:: Copyright (c) 2009 Internuity Ltd
# Licence:: MIT License (http://www.opensource.org/licenses/mit-license.php)
#

require 'awsum/parser'
require 'awsum/requestable'
require 'awsum/support'

require 'awsum/ec2'
require 'awsum/s3'

module Awsum

  VERSION = "0.4"

  API_VERSION = '2009-03-01'
  SIGNATURE_VERSION = 2
end


