module RubyCraft
  class ScaevolusRegion < Region
    def initialize(*)
      @chunks = Array.new(32) { Array.new(32) }
      super
    end

    def chunk(z, x)
      @chunks[z][x]
    end

    def unloadChunk(z, x)
      @chunks[z][x]._unload
    end

    def each(&block)
      @chunks.each do |line|
        line.each do |chunk|
          yield chunk
        end
      end
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
