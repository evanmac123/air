When /^I fill in most of my demographic information$/ do
  When %{I fill in "Weight" with "230"}
  And %{I select "6 ft." from the feet select}
  And %{I select "3 in." from the inches select}
  And %{I choose "Male"}
end

When /^I fill in all of my demographic information$/ do
  When %{I fill in "Weight" with "230"}
  And %{I select "6 ft." from the feet select}
  And %{I select "3 in." from the inches select}
  And %{I choose "Male"}
  And %{I fill in "Date of Birth" with "September 10, 1977"}
end
