require 'rubycraft/block_type'

module RubyCraft
  # A minecraft block. Its position is given by a coord[x, z, y]
  class AnvilBlock < Block
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