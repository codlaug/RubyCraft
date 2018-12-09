module RubyCraft
  class ChunkCube
    include Enumerable

    # width corresponds do z, length to x, and height to y.
    def initialize(region, initialPos, width, length, height)
      @region = region
      @initialPos = initialPos
      @width = width || 1
      @length = length || 1
      @height = height || 1
    end

    def each(&block)
      z, y, x = @initialPos # anvil format
      firstChunkX = x / chunkSide
      firstChunkZ = z / chunkSide
      lastChunkX = (x + @length - 1) / chunkSide
      lastChunkZ = (z + @width - 1) / chunkSide
      for j in firstChunkZ..lastChunkZ
        for i in firstChunkX..lastChunkX
          iterateOverChunk j, i, &block
        end
      end
    end

    protected
    def iterateOverChunk(j, i, &block)
      chunk = @region.chunk(j, i)
      return if chunk.nil?
      z, y, x = @initialPos # anvil format
      chunk.each do |b|
        globalZ = b.z + (j * chunkSide)
        globalX = b.x + (i * chunkSide)
        if globalZ.between?(z, z + @width - 1) and
            globalX.between?(x, x + @length - 1) and
            b.y.between?(y, y + @height - 1)
          yield b, globalZ - z, globalX - x , b.y - y
        end
      end
      @region.unloadChunk(j, i)
    end

    def chunkSide
      16
    end
  end
end
