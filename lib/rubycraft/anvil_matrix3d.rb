require 'rubycraft/matrix3d'
module RubyCraft
  
    class AnvilMatrix3d < Matrix3d
      include Enumerable
  
      def [](x, y, z)
        @data[y][x][z]
      end
  
      def []=(x, y, z, value)
        @data[y][x][z] = value
      end
  
      def each(&block)
        for z in @data
          for x in z
            for y in x
              yield y
            end
          end
        end
      end
  
      def each_triple_index(&block)
        return enum_for:each_triple_index unless block_given?
        @data.each_with_index do |plane, y|
          plane.each_with_index do |column, x|
            column.each_with_index do |value, z|
              yield value, y, z, x
            end
          end
        end
      end
  
      def to_a(default = nil)
        map do |y|
          if y.nil?
            default
          else
            y
          end
        end
      end
  
      protected
      def indexToArray(index)
        y = index / (@zlimit * @xlimit)
        index -= y * (@zlimit * @xlimit)
        x = index / @zlimit
        z = index % @zlimit
        return x, y, z
      end
  
  
    end
  end
  