module RubyCraft
  VERSION = "0.1.1".freeze

  autoload :Region              ,'rubycraft/region'
  autoload :Chunk               ,'rubycraft/chunk'
  autoload :Block               ,'rubycraft/block'
  autoload :LazyChunk           ,'rubycraft/lazy_chunk'
  autoload :ByteConverter       ,'rubycraft/byte_converter'
  autoload :ZlibHelper          ,'rubycraft/zlib_helper'
  autoload :RegionWriter        ,'rubycraft/region_writer'
end

require 'rubycraft/region'
