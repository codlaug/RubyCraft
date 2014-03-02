module RspecExtensions
  # Helper method to handle exceptions
  def raisesException(nameError = Exception, &block)
    block.should raise_error(nameError)
  end
end

module RspecDSLExtensions
  # disable all tests. mark the test to be kept as rit. Useful for debugging tests.
  def off
    class << self
      def ignoredIt(*args)

      end

      alias_method :rit, :it
      alias_method :it, :ignoredIt
    end
  end
end


class RSpec::Core::ExampleGroup
  include RspecExtensions
  extend RspecDSLExtensions
end
