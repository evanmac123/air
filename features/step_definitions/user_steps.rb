Given /^"(.*?)" has a claim code$/ do |username|
  User.find_by_name(username).generate_simple_claim_code!
end

Then /^"(.*?)" should be claimed by "(.*?)"$/ do |username, phone_number|
  user = User.find_by_name(username)
  user.phone_number.should == phone_number
  user.claim_code.should be_nil
end

Then /^"(.*?)" should not be claimed$/ do |username|
  User.find_by_name(username).phone_number.should be_blank
end
