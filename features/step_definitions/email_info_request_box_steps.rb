When /^I enter "([^"]*)" in the (\w+) field of the top email info box$/ do |entry, input_name|
  with_scope '#request-consultation-bar' do
    fill_in("email[#{input_name}]", :with => entry)
  end
end

When /^I submit the top email info box$/ do
  with_scope '#request-consultation-bar' do
    find("input[type=image]").click
  end
end
