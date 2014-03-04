module RubyCraft
  class ScaevolusRegion < Region
    def initialize(*)
      super
    end

    def default_chunk_class
      ScaevolusChunk
    end

    protected
  end
end
