module RubyCraft
  class RegionWriter
    def initialize(io)
      @io = io
    end

    def pad(count, value = 0)
      self << Array.new(count) { value }
    end

    def <<(input)
      @io <<  ByteConverter.toByteString( Array(input) )
    end

    def close
      @io.close
    end
  end

end
