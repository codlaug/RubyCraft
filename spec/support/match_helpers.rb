module MatchHelpers
  def self.same_set(x, y)
    x.size == y.size and x.to_set == y.to_set
  end
end


