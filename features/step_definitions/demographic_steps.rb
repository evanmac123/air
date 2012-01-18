When /^I fill in most of my demographic information$/ do
  When %{I choose "Male"}
end

When /^I fill in all of my demographic information$/ do
  When %{I choose "Male"}
  And %{I fill in "Date of Birth" with "September 10, 1977"}
end
