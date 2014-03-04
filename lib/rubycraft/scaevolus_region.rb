module RubyCraft
  class ScaevolusRegion < Region
    def initialize(*)
      super
    end

    protected
    def populateChunks
      @bytes[0..(blockSize - 1)].each_slice(4).each_with_index do |ar, i|
        offset = bytesToInt [0] + ar[0..-2]
        count = ar.last
        if count > 0
          @chunks[i / 32][i % 32 ] = readChunk(offset)
        end
      end
    end
  end
end
