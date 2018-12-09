require 'rubycraft/block_type'

module RubyCraft
  # A minecraft block. Its position is given by a coord[x, z, y]
  class Block

    attr_accessor :block_type, :pos, :data
    def initialize(block_type, data = 0)
      @block_type = block_type
      @data = 0
    end

    def self.get(key)
      new BlockType.get key
    end

    def self.of(key)
      self[key]
    end

    def self.[](key)
      new BlockType[key]
    end


    def color=(color)
      @data = BlockColor::InvertedColor[color]
    end

    def color
      BlockColor.typeColor[@data].name
    end

    def blockColor
      BlockColor.typeColor[@data]
    end

    def is(name)
      self.name == name.to_s
    end

    def name
      @block_type.name
    end

    def id
      @block_type.id
    end

    def transparent
      @block_type.transparent
    end

    #sets block type by name
    def name=(new_name)
      return if name == new_name.to_s
      @block_type = BlockType[new_name]
    end

    #sets block type by id
    def id=(id)
      return if id == id
      @block_type = BlockType.get id
    end

    def y
      pos[2]
    end

    def z
      pos[1]
    end

    def x
      pos[0]
    end
  end
end