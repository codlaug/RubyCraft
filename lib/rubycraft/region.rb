module RubyCraft
  # Enumerable over chunks
  class Region < BinaryBunch
    def initialize(*)
      super
      populateChunks
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

    def chunk_string
      @chunks.map do |line|
        line.map do |chunk|
          if chunk.nil?
            '?'
          else
            'X'
          end
        end.join
      end.join("\n")
    end

    def cube(z, y, x, opts = {}, &block)
      c = ChunkCube.new(self, [z, y, x], opts[:width], opts[:length], opts[:height])
      return c unless block_given?
      c.each &block
    end

    def exportTo(io)
      output = RegionWriter.new io
      chunks = get_nbt_chunks
      writeChunkOffsets output, chunks
      output.pad block_size, dummytimestamp
      writeChunks output, chunks
      output.close
    end

    def chunks_count_per_side
      options.fetch(:chunks_count_per_side) { 32 }
    end

    def block_size
      options.fetch(:block_size) { 4096 }
    end

    protected
    def populateChunks
      side = chunks_count_per_side
      @chunks = Array.new(side) { Array.new(side) }
      @bytes[0..(block_size - 1)].each_slice(4).each_with_index do |ar, i|
        offset = bytesToInt [0] + ar[0..-2]
        count = ar.last
        if count > 0
          @chunks[i / side][i % side ] = readChunk(offset)
        end
      end
    end

    def readChunk(offset)
      o = offset * block_size
      bytecount = bytesToInt @bytes[o..(o + 4)]
      o += 5
      lazy_chunk @bytes[o..(o + bytecount - 2)]
    end

    def lazy_chunk(nbtBytes)
      LazyChunk.new nbtBytes, @options.merge(chunk_class: chunk_class)
    end

    def chunk_class
      @options.fetch(:chunk_class) { default_chunk_class }
    end

    def chunkSize(chunk)
      chunk.size + chunkMetaDataSize
    end

    def chunkBlocks(chunk)
      ((chunkSize chunk).to_f / block_size).ceil
    end

    def writeChunks(output, chunks)
      for chunk in chunks
        next if chunk.nil?
        output << intBytes(chunk.size + 1)
        output << defaultCompressionType
        output << chunk
        remaining = block_size - chunkSize(chunk)
        output.pad remaining % block_size
      end
    end

    def writeChunkOffsets(output, chunks)
      lastVacantPosition = 2
      for chunk in chunks
        if chunk
          sizeCount = chunkBlocks chunk
          output << intBytes(lastVacantPosition)[1..3]
          output << sizeCount
          lastVacantPosition += sizeCount
        else
          output.pad 4
        end
      end
    end

    def get_nbt_chunks
      map do |chunk|
        if chunk.nil?
          nil
        else
          chunk.toNbt
        end
      end
    end
  
    def chunkMetaDataSize
      5
    end

    def defaultCompressionType
      2
    end

    def dummytimestamp
      0
    end

  end
end
