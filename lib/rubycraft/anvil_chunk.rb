require 'rubycraft/section'

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

    Height = 256

    def parse_blocks
      level['Sections'].each do |section|
        y = section['Y'].value
        sections[y] = Section.new(section)
      end
    end

    def sections
      # A chunk can have fewer than 16 sections
      # how do I store that data?
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
      sections[y] ||= Section.new(find_section_by_y(y))
    end

    def find_section_by_y y
      level['Sections'].find do |section|
        y == section['Y'].value
      end
    end

    def each(&block)
      sections.compact.each do |section|
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

    def export
      secs = @sections.map{|sec| sec.export if not sec.nil? }.compact
      level["Sections"] = NBTFile::Types::List.new(NBTFile::Types::Compound, secs)
      level["HeightMap"] = exportHeightMap
      ["", @nbtBody]
    end

    protected
    def exportHeightMap
      height_map = level["HeightMap"].values
      xwidth = Width
      each do |b|
        unless b.transparent
          y, z, x = b.pos
          height_map[z*xwidth + x] = [height_map[z*xwidth + x], y+1].max
        end
      end
      return NBTFile::Types::IntArray.new(height_map)
    end

  end
end
