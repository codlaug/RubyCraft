module RubyCraft
  class RegionWriter
    def initialize(io)
      @io = io
    end

    def pad(count, value = 0)
      self << Array.new(count) { value }
    end

    def <<(o)
      input = o.kind_of?(Array) ? o : [o]
      @io <<  ByteConverter.toByteString(input)
    end

    def close
      @io.close
    end
  end

end
