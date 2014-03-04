module RubyCraft
  VERSION = "0.1.1".freeze

  autoload :BinaryBunch         ,'rubycraft/binary_bunch'
  autoload :Region              ,'rubycraft/region'
  autoload :AnvilRegion         ,'rubycraft/anvil_region'
  autoload :ScaevolusRegion     ,'rubycraft/scaevolus_region'
  autoload :Chunk               ,'rubycraft/chunk'
  autoload :AnvilChunk          ,'rubycraft/anvil_chunk'
  autoload :ScaevolusChunk      ,'rubycraft/scaevolus_chunk'
  autoload :ChunkCube           ,'rubycraft/chunk_cube'
  autoload :Block               ,'rubycraft/block'
  autoload :LazyChunk           ,'rubycraft/lazy_chunk'
  autoload :ByteConverter       ,'rubycraft/byte_converter'
  autoload :ZlibHelper          ,'rubycraft/zlib_helper'
  autoload :RegionWriter        ,'rubycraft/region_writer'
end

require 'rubycraft/region'
