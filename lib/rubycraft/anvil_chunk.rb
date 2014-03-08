module RubyCraft
  class AnvilChunk < Chunk
    def parse_blocks
      BlockMatrix.new(*dimensions).tap do |matrix|
        sections.each do |section|
          blocks = section['Blocks'].value.bytes
          data   = section['Data'].value.bytes
          blocks.each_with_index do |byte, index|
            value = extract_data_half_byte data[index / 2], index
            matrix.put_block index, byte, value
          end
        end
      end
    end

    def sections
      level['Sections']
    end

    def extract_data_half_byte(value, index)
      if index % 2 == 0
        value & 0xF
      else
        value >> 4
      end
    end
  end
end
