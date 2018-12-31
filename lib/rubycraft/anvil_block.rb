require 'rubycraft/block_type'

module RubyCraft
  # A minecraft block. Its position is given by a coord[x, z, y]
  class AnvilBlock < Block
    def self.get(key)
      puts '-------'
      puts key.inspect
      new BlockType.get key.split(':')[1]
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