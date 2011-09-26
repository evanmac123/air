When /^I enter the following into the bulk information area:$/ do |string|
  fill_in "bulk_user_data", :with => string
end
