require 'rubycraft/anvil_matrix3d'
require 'rubycraft/anvil_block'

module RubyCraft
  class Section
    include Enumerable
    include ZlibHelper

    Width = 16
    Length = 16
    Height = 16

    def initialize(section)
      if section
        @is_empty = false
        @base_y = section["Y"].value * Height
        @nbt_section = section
        @blocks = AnvilMatrix3d.new(Width, Length, Height).fromArray(blocks_from_nbt(section))
        @blocks.each_triple_index do |b, y, x, z|
          b.pos = [y + @base_y, z, x]
        end
        if section['Data']
          data = section["Data"].value.bytes.to_a
          @blocks.each_with_index do |b, index|
            v = data[index / 2]
            if index % 2 == 0
              b.data = v & 0xF
            else
              b.data = v >> 4
            end
          end
        end
      else
        @is_empty = true
        @base_y = 0
        @blocks = AnvilMatrix3d.new(Width, Length, Height)
      end
    end

    def nil?
      @is_empty
    end

    def each(&block)
      @blocks.each &block
    end

    def block_map(&block)
      each { |b| b.name = yield b }
    end

    def block_type_map(&block)
      each { |b| b.name = yield b.name.to_sym }
    end

    def [](y, z, x)
      @blocks[z, y - @base_y, x]
    end

    def []=(y, z, x, value)
      value.pos = [y, z, x]
      @blocks[z, y - @base_y, x] = value
    end

    def to_a
      @blocks.to_a
    end

    def export
      @nbt_section
      # @nbt_section["Data"] = byte_array(export_level_data)
      # block_ids = @blocks.map(&:id)
      # @nbt_section["Blocks"] = byte_array(block_ids)
      # if block_ids.any?{|id| id > 255}
      #   adds = block_ids.map.with_index do |_,i|
      #     (i % 2 == 0) ? [block_ids[i], block_ids[i+1]] : nil
      #   end.compact.map do |b1, b2|
      #     ((b2 >> 8) << 4) + (b1 >> 8)
      #   end
      #   @nbt_section["Add"] = byte_array(adds)
      # end
      # return @nbt_section
    end

    private
    def export_level_data
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

    def byte_array(data)
      NBTFile::Types::ByteArray.new ByteConverter.toByteString(data)
    end

    class Palette
      attr_accessor :name, :properties
      def initialize compound
        @name = compound['Name'].value
        @properties = compound['Properties']&.keys # FIXME
      end
    end

    def blocks_from_nbt(section)
      palette = section['Palette'].each.map{|c| Palette.new(c) }

      if section["Blocks"]
        block_bytes = section["Blocks"].value.bytes
      elsif section['BlockStates']
        block_bytes = get_block_array(section['BlockStates'].value)
      end
      if section["Add"]
        add_bytes = section["Add"].value.bytes.map{|b| [b & 15, b >> 4] }.flatten
        return block_bytes.zip(add_bytes).map{|b, a| AnvilBlock.get((a << 8) + b) }
      else
        if section['BlockStates']
          block_bytes.map do |b|
            if palette[b]
              AnvilBlock.get(palette[b].name)
            else
              # raise "NOT FOUND"
              AnvilBlock.get_from_global_palette(b)
            end
          end
        else
          return block_bytes.map{|b| AnvilBlock.get(b) }
        end
      end
    end


    def get_block_array(blockstates)

      return_value = [0] * 4096
      bit_per_index = blockstates.length * 64 / 4096
      current_reference_index = 0
  
      blockstates.length.times do |i|
        current = blockstates[i]

        overhang = (bit_per_index - (64 * i) % bit_per_index) % bit_per_index
        if overhang > 0
          return_value[current_reference_index - 1] |= current % ((1 << overhang) << (bit_per_index - overhang))
        end
        current = current >> overhang

        remaining_bits = 64 - overhang
        ((remaining_bits + (bit_per_index - remaining_bits % bit_per_index) % bit_per_index) / bit_per_index).times do
          return_value[current_reference_index] = current % (1 << bit_per_index)
          current_reference_index += 1
          current >>= bit_per_index
        end
      end

      return_value #.each_slice(16).each_slice(16).to_a
    end
  end
end