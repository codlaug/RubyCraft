RSpec::Matchers.define :contain_names do |*args|
  match do |orm_result|
    MatchHelpers.same_set orm_result.map_by(:name), args.map_by(:to_s)
  end

  failure_message_for_should do |actual|
    "got #{actual.map_by(:name).inspect}, but expected #{expected.map_by(:to_s).inspect}"
  end

  failure_message_for_should_not do |actual|
    "expected that #{actual.map_by(:name).inspect} would not be #{expected.map_by(:to_s).inspect}"
  end
end

