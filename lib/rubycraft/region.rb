module RubyCraft
  # Enumerable over chunks
  class Region
    include Enumerable
    include ByteConverter
    include ZlibHelper

    def self.from_file(filename)
      path = Pathname.new(filename).expand_path
      if path.extname == '.mca'
        AnvilRegion
      else
        ScaevolusRegion
      end.fromFile(path)
    end

    def self.fromFile(filename)
      new ByteConverter.stringToByteArray IO.read filename
    end

    def initialize(bytes, options = {})
      raise "Must be an io" if bytes.kind_of?(String)
      @bytes = bytes
      @options = options
      populateChunks
    end

    def inspect
      %Q~<#{self.class} (#{@bytes.length} bytes)>~
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
      output.pad blockSize, dummytimestamp
      writeChunks output, chunks
      output.close
    end

    def exportToFile(filename)
      File.open(filename, "wb") { |f| exportTo f }
    end


    protected
    def readChunk(offset)
      o = offset * blockSize
      bytecount = bytesToInt @bytes[o..(o + 4)]
      o += 5
      nbtBytes = @bytes[o..(o + bytecount - 2)]
      LazyChunk.new nbtBytes, @options
    end

    def chunkSize(chunk)
      chunk.size + chunkMetaDataSize
    end

    def chunkBlocks(chunk)
      ((chunkSize chunk).to_f / blockSize).ceil
    end

    def writeChunks(output, chunks)
      for chunk in chunks
        next if chunk.nil?
        output << intBytes(chunk.size + 1)
        output << defaultCompressionType
        output << chunk
        remaining = blockSize - chunkSize(chunk)
        output.pad remaining % blockSize
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

    def blockSize
      4096
    end

  end
end
