When /^I enter "([^"]*)" in the name field of the top email info box$/ do |name|
  with_scope("#request-consultation-bar") do
    fill_in "email[name]", :with => name
  end
end

When /^I enter "([^"]*)" in the email field of the top email info box$/ do |email|
  with_scope("#request-consultation-bar") do
    fill_in "email[email]", :with => email
  end
end

When /^I submit the top email info box$/ do
  with_scope("#request-consultation-bar") do
    page.find(:css, "input[@type=image]").click
  end
end

