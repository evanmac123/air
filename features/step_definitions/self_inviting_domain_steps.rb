Then /^I should( not)? see the self\-inviting domain "([^"]*)"$/ do |sense, domain|
  sense = !sense

  if sense
    page.should have_css("li.domain", :text => domain)
  else
    page.should have_no_css("li.domain", :text => domain)
  end
end

