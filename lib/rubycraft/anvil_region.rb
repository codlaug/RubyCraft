module RubyCraft
  class AnvilRegion < Region
    def initialize(*)
      super
    end

    def default_chunk_class
      AnvilChunk
    end

    protected
  end
end
