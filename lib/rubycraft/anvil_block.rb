require 'rubycraft/block_type'

module RubyCraft
  # A minecraft block. Its position is given by a coord[x, z, y]
  class AnvilBlock < Block
    def self.get(key, type)
      puts '-------'
      puts type.inspect
      puts key.inspect
      puts (key & 0xF).inspect
      puts (key >> 4).inspect
      new BlockType.get key
    end

    def self.intBytes(i)
      [i >> 24, (i >> 16) & 0xFF, (i >> 8) & 0xFF, i & 0xFF]
    end

    def y
      pos[0]
    end
  
    def z
      pos[1]
    end
  
    def x
      pos[2]
    end
  end
end