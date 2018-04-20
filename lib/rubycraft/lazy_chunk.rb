module RubyCraft
  # TODO would actually make a good module, includable in all *Chunk
  class LazyChunk
    include ByteConverter
    include ZlibHelper

    def initialize(bytes, options = {})
      @bytes = bytes
      @options = options
      @chunk = nil
    end

    def each(&block)
      _getchunk.each &block
    end

    def each_non_empty(&block)
      _getchunk.each_non_empty &block
    end

    def block_map(&block)
      _getchunk.block_map &block
    end
    def block_type_map(&block)
      _getchunk.block_type_map &block
    end

    def section(y)
      _getchunk.section(y)
    end

    def [](z, x, y)
      _getchunk[z, x, y]
    end

    def []=(z, x, y, value)
      _getchunk[z, x, y] = value
    end

    def export
      _getchunk.export
    end


    def toNbt
      return @bytes if @chunk.nil?
      @chunk.toNbt
    end


    # unloacs the loaded chunk. Needed for memory optmization
    def _unload
      return if @chunk.nil?
      @bytes = @chunk.toNbt
      @chunk = nil
    end

    protected
    def _getchunk
      if @chunk.nil?
        @chunk = chunk_class.fromNbt @bytes, @options
      end
      @chunk
    end

    def chunk_class
      @options.fetch(:chunk_class) { Chunk }
    end
  end
end
