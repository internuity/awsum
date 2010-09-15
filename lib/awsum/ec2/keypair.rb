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

    class KeyPairParser < Awsum::Parser #:nodoc:
      def initialize(ec2)
        @ec2 = ec2
        @key_pairs = []
        @text = nil
        @stack = []
      end

      def tag_start(tag, attributes)
        #Quick hack so we can use the same parser for CreateKeyPair which doesn't use the item tag to wrap the key pair information
        if tag == 'CreateKeyPairResponse'
          @stack << 'keySet'
        end

        case tag
          when 'keySet'
            @stack << 'keySet'
          when 'item', 'CreateKeyPairResponse'
            case @stack[-1]
              when 'keySet'
                @current = {}
                @text = ''
            end
        end
      end

      def text(text)
        @text << text unless @text.nil?
      end

      def tag_end(tag)
        case tag
          when 'DescribeKeyPairsResponse'
            #no-op
          when 'keySet'
            @stack.pop
          when 'item', 'CreateKeyPairResponse'
            case @stack[-1]
              when 'keySet'
                @key_pairs << KeyPair.new(
                              @ec2,
                              @current['keyName'], 
                              @current['keyFingerprint'],
                              @current['keyMaterial']
                            )
                @text = ''
            end
          else
            unless @text.nil?
              text = @text.strip
              @current[tag] = (text == '' ? nil : text)
              @text = ''
            end
        end
      end

      def result
        @key_pairs
      end
    end
  end
end
