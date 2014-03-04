# Represents a chunk data
require 'rubycraft/nbt_helper'
require 'rubycraft/byte_converter'
require 'rubycraft/block'
require 'rubycraft/matrix3d'

module RubyCraft
  # Chunks are enumerable over blocks
  class Chunk < BinaryBunch

    Width = 16
    Length = 16
    Height = 128

    def self.fromNbt(bytes, *a)
      new bytes, *a
    end

    def initialize(bytes, options = {})
      @bytes = true # do not store
      super
      if bytes.length == 2
        name, @nbtBody = bytes
      else
        name, @nbtBody = NbtHelper.fromNbt(bytes)
      end
      unless options[:no_blocks]
        @blocks = parse_blocks
      end
    end

    def dimensions
      @options.fetch(:chunk_dimensions) { [Width, Length, Height] }
    end

    # Iterates over the blocks
    def each(&block)
      @blocks.each &block
    end


    # Converts all blocks on data do another type. Gives the block and sets
    # the received name
    def block_map(&block)
      each { |b| b.name = yield b }
    end

    # Converts all blocks on data do another type. Gives the block name sets
    # the received name
    def block_type_map(&block)
      each { |b| b.name = yield b.name.to_sym }
    end

    def [](z, x, y)
      @blocks[z, x, y]
    end

    def []=(z, x, y, value)
      @blocks[z, x, y] = value
    end

    def export
      level["Data"] = byteArray exportLevelData
      level["Blocks"] = byteArray @blocks.map { |b| b.id }
      level["HeightMap"] = byteArray exportHeightMap
      ["", @nbtBody]
    end

    def toNbt
      NbtHelper.toBytes export
    end

    protected
    def exportHeightMap
      zwidth, xwidth, ywidth = @blocks.bounds
      matrix = Array.new(zwidth) { Array.new(xwidth) { 1 }}
      @blocks.each_triple_index do |b, z, x, y|
        unless b.transparent
          matrix[z][x] = [matrix[z][x], y + 1].max
        end
      end
      ret = []
      matrix.each do |line|
        line.each do |height|
          ret << height
        end
      end
      ret
    end

    def level
      @nbtBody["Level"]
    end

    def sections
      level['Sections']
    end

    def exportLevelData
      data = []
      @blocks.each_with_index do |b, i|
        if i % 2 == 0
          data << b.data
        else
          data[i / 2] += (b.data << 4)
        end
      end
      data
    end

    def byteArray(data)
      NBTFile::Types::ByteArray.new ByteConverter.toByteString(data)
    end

    def parse_blocks
      BlockMatrix.new(*dimensions).tap do |matrix|
        if sections # instead of raw array, Chunk is devided into Sections
          parse_anvil_blocks matrix
        else
          parse_mc_region_blocks matrix
        end
      end
    end

    def parse_anvil_blocks(matrix)
      sections.each do |section|
        blocks = section['Blocks'].value.bytes
        data   = section['Data'].value.bytes
        blocks.each do |byte|
          matrix.append_block byte, data[matrix.current_index / 2]
        end
      end
    end

    def parse_mc_region_blocks(matrix)
      blocks = level['Blocks'].value.bytes
      data   = level['Data'].value.bytes
      blocks.each do |byte|
        matrix.append_block byte, data[matrix.current_index / 2]
      end
    end

    class BlockMatrix < Matrix3d
      def initialize(*)
        super
        @index = 0
      end
      # must be done sequentally
      def append_block(byte, data)
        block = Block.get(byte)
        block.data = extract_data_half_byte data
        block.pos = *indexToArray(@index)
        put @index, block
        @index += 1
      end

      def extract_data_half_byte(value)
        if @index % 2 == 0
          value & 0xF
        else
          value >> 4
        end
      end

      def current_index
        @index
      end

    end

  end
end
