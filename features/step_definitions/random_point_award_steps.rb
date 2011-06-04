Given /^the RNG is( not)? predisposed to hand out bonus points$/ do |sense|
  sense = !sense

  BonusThreshold.any_instance.stubs(:probabilistically_award_points?).returns(sense)
end
