module Awsum
  class Ec2
    class State
      attr_reader :code, :name

      def initialize(code, name)
        @code = code.to_i
        @name = name
      end

      def ==(other)
        if other.is_a?(Numeric)
          @code == other
        elsif other.is_a?(String)
          @name == other
        else
          @code = other.code && @name == other.name
        end
      end
    end
  end
end
