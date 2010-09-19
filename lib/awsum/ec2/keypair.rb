require 'awsum/ec2/parsers/keypair_parser'

module Awsum
  class Ec2
    class KeyPair
      attr_reader :name, :fingerprint, :material

      def initialize(ec2, name, fingerprint, material)
        @ec2 = ec2
        @name = name
        @fingerprint = fingerprint
        @material = material
      end
    end
  end
end
