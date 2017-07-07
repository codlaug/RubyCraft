module RubyCraft
  class AnvilChunk < Chunk
    # In the Anvil format, block positions are ordered YZX for compression purposes.
    # The coordinate system is as follows:
    #  * X increases East, decreases West
    #  * Y increases upwards, decreases downwards
    #  * Z increases South, decreases North

    # The major change from MCRegion to Anvil was the division of Chunks into
    # Sections; each chunk has up to 16 individual 16×16×16 block Sections so
    # that completely empty sections will not be saved at all.

    def parse_blocks
      level['Sections'].each do |section|
        blocks = section['Blocks'].value.bytes
        data   = section['Data'].value.bytes
        y      = section['Y'].value
        section(y).tap do |section|
          blocks.each_with_index do |byte, index|
            value = extract_data_half_byte data[index / 2], index
            section.put_block index, byte, value
            # TODO position
          end
        end
      end
    end

    def sections
      @sections ||= Array.new(16)
    end

    def section_by_coord(coord)
      raise(ArgumentError, 'must be 0 or greater') if coord < 0
      raise(ArgumentError, 'must be lesser than 256') if coord >= 256
      section section_index(coord)
    end

    def section(y)
      raise(ArgumentError, 'must be 0 or greater') if y < 0
      raise(ArgumentError, 'must be lesser than 16') if y >= 16
      sections[y] ||= BlockMatrix.new(16,16,16)
    end

    def each(&block)
      sections.each do |section|
        section.each(&block)
      end
    end

    def each_non_empty(&block)
      sections.reject(&:nil?).each do |section|
        section.each(&block)
      end
    end

    def [](y, z, x)
      section_by_coord(y)[y % 16, z, x]
    end

    def []=(y, z, x, value)
      section_by_coord(y)[y % 16, z, x] = value
    end

    def section_index(y)
      y >> 4
    end
  end
end
