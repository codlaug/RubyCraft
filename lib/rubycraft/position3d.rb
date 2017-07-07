module RubyCraft
  class Position3D < Struct.new(:x, :y, :z)
    module FromArray
      def yzx
        ensure_3_elements
        Position3D.new(self[2], self[0], self[1])
      end

      def xzy
        ensure_3_elements
        Position3D.new(self[0], self[2], self[1])
      end

      def ensure_3_elements
        raise(ArgumentError, "must have exactly 3 elements, but had #{length}") unless length == 3
      end
    end

    Array.class_eval do
      include FromArray
    end
  end
end
