require 'spec_helper'

module Awsum
  describe Ec2::KeyPairParser do
    subject { Ec2.new('abc', 'xyz') }
    let(:ec2) { subject }
    let(:parser) { Awsum::Ec2::KeyPairParser.new(ec2) }

    describe "parsing the result of a call to DescribeKeyPairs" do
      let(:result) { parser.parse(fixture('ec2/key_pairs')) }

      it "should return an array of key pairs" do
        result.should be_a(Array)
      end

      context "the first key pair" do
        let(:key_pair) { result.first }

        {
          :name         =>  'gsg-keypair',
          :fingerprint  =>  'ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab'
        }.each do |key, value|
          it "should have the correct #{key}" do
            key_pair.send(key).should == value
          end
        end
      end
    end

    describe "parsing the result of a call to CreateKeyPair" do
      let(:result) { parser.parse(fixture('ec2/create_key_pair')) }

      it "should return an array of key pairs" do
        result.should be_a(Array)
      end

      context "the first key pair" do
        let(:key_pair) { result.first }

        {
          :name         => 'test-keypair',
          :fingerprint  => 'ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab',
          :material     => %q{-----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAqkxIjNxLV/shvaep5Kum3N2xTV6aBbXezVA4HHE371HSq3haKTcST7QYeQha
92AmZojAm2ojqWMw9GJaeq/Q7NvXKdMgj3mKd7zY7tdC+HmKYVkAvJ9enuuVwPFxlt+5rPpZ2jS+
kl4MWEvWh1N5U1urx5gzHq2e/k7P+dCBwFnCHsg/p1mym4j4qwEHEviaUG6SnB8Xvuggp/pxCmJg
9Gie4cXNgbBboEyAQDRb/AmrehbBa90GOVDjDGIzB98rOcJ22FRrpLqSl2D+FQKsXWboqgbIrgKT
ven7mzb8cgDJNrWTI/MNP8p8gNTh+L7gTwPDcGfaDBiRpn9t3FiTBwIDAQABAoIBAEmuNZmUWpjX
U/LdjtkcF1bqKCMkchlUZfCI664KojvOOAruSHwakrafYhNDtS/gjtzAAC19z64i93RU9XatiQRh
3YcADM9ms604rNcxlY0x8NhLjNEPVv4FScav8AhqBci8jJGnTmi/fjHZphjo2c5iFEGILV3xmp/G
857PQsQ4nOAzoV7fQPYow4XiO/xhGh8p8o2Z9Og3GdbEGH1v/051g3O1eU7PFyQaxmOGNYmklMuM
V/8l/LK+OKR0f9KgqcgDSlEbidqsmWM0a1/t7+I5W/mgXSZl5U4HN680DKbkzoX0kgoPN7XMbcSX
sHNguqDfrvkBUQu1vEaXebWfpekCgYEA0qVbcFGxKniyYxmvtSrbb5bpEnh6zRCGXgSU4fX41i8P
Xg15R7FnwGO5nuRXqGW6CSgfbA7YAVEQHunUOB0XWuJWgn6gsqvnCZvyfRnqyMJJjRhvuaUMTn/5
ikcayflqPFHvv5Z+pB3pWNaTD6lM5imdF1In9RBYL4q5Vpt9gl0CgYEAzvb6cS6Yi0PkxU3OOEmg
98QcdTEd1hrk3r6uXI1TOeiUPIw+dyGCKa9OqpcFDs+0FskFs6RzztRh2gpwQZTH3UOYPqsjsWd+
AjL3jv+vmpU1OhnA0SpkyiiZtaSAV2N+Xlq8orG6fbnYFCdzHbufLFaoOpbGptmLfrwMSvnhXLMC
gYBxRsEcbqHycAOmLUsDBvAIW0QtTaLkIe3QI3CY7viI3bfK4T4GIs3jdP1+B9dn1IStpej36Cea
1afwp9ga8PH9Stgwxr3ON4k/7qABTG2o1mpNOQXj9HDgygs8pC4wzTKnC3z9L4Yc5YT15DYjZuzW
nSxAPUsFi2uQ7W3ruCRPdQKBgGslsCiyb+UBpEmFa3L2o3BCRl1hrUmwKLcszsY5oFHFmCD0lk5E
ucds6/QjNUoiu+Bj+CC1zgLRL0ubxdwd848YtJQVM+hfZPwseL++naIRBzpqJMnlAcMrW9CPNqaH
at/cZ/ZuvtbiRPzCI7XL8a8ZugSDFJtC2xYkstSKI2NDAoGAIiwUwKRMJyB9IRXhMfpf6vsEza2t
urHVUdJUyIwvPJSh2PfkumwrPuk+P+8v6jJjJ0hsqOS+TLQwWclIGwGey/PMNRYqQDqnSUofNmza
XtGGfWTOD3AdDEH39RTd3Zmfirrjm1YsY/Nb54X+V5TN2uvm/yJBIbb4aLvfG74Jmoc=
-----END RSA PRIVATE KEY-----}
        }.each do |key, value|
          it "should have the correct #{key}" do
            key_pair.send(key).should == value
          end
        end
      end
    end
  end
end
