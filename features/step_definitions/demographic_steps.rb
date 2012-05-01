When /^I fill in most of my demographic information$/ do
  step %{I choose "Male"}
end

When /^I fill in all of my demographic information$/ do
  step %{I choose "Male"}
  step %{I fill in "Date of Birth" with "September 10, 1977"}
end
