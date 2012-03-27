Given /^the RNG is( not)? predisposed to hand out bonus points$/ do |sense|
  sense = !sense

  BonusThreshold.any_instance.stubs(:probabilistically_award_points?).returns(sense)
end

Then /^"([^"]*)" should have "([^"]*)" points$/ do |name, points|
  user = User.find_by_name(name)
  user.points.should == points.to_i
end
