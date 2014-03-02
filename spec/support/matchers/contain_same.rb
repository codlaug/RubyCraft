RSpec::Matchers.define :contain_same do |*args|
  match do |collection|
    if args.to_set.size != args.size
      raise ArgumentError.new "Args must not contain repeated elements"
    end
    MatchHelpers.same_set collection, args
  end

  failure_message_for_should do |actual|
    if actual.to_set != expected.to_set
      "got #{actual.inspect}, but expected #{expected.inspect}"
    else
      dups = Set.new
      test_set = Set.new
      actual.each {|val| dups.add(val) unless test_set.add?(val)}
      "both are the same as set, however, actual has more repeated elements: #{dups.to_a.inspect}"
    end
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual.map_by(:name).inspect} would not be #{expected.map_by(:to_s).inspect}"
  end
end
