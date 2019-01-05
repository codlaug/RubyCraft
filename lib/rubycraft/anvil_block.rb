require 'rubycraft/block_type'
require 'json'

module RubyCraft
  # A minecraft block. Its position is given by a coord[x, z, y]
  class AnvilBlock < Block
    def self.get(key)
      new BlockType.get key.split(':')[1]
    end

    GLOBAL_PALETTE = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'runtimeid_table.json')))

    def self.get_from_global_palette(id)
      new BlockType.get GLOBAL_PALETTE[id]['name'].split(':')[1]
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