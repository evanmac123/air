def set_time_inputs(input_prefix, time_string)
  month,day,year,hour,minute = time_string.split("/")
  {"1i" => year, "2i" => month, "3i" => day, "4i" => hour, "5i" => minute}.each do |suffix, value|
    select value, :from => "demo_#{input_prefix}_#{suffix}"
  end
end

Given /^"([^"]*)" has victory threshold (\d+)$/ do |demo_name, victory_threshold_string|
  demo = Demo.find_by_company_name(demo_name)
  demo.victory_threshold = victory_threshold_string.to_i
  demo.save!
  demo.reload
end

When /^I set the start time to "([^"]*)"$/ do |time_string|
  set_time_inputs("begins_at", time_string)
end

When /^I set the end time to "([^"]*)"$/ do |time_string|
  set_time_inputs("ends_at", time_string)
end

Then /^I should see a list of demos$/ do
  within "ul.demos" do
    page.should have_css("li a", :text => "3M")
    page.should have_css("li a", :text => "Fidelity")
    page.should have_css("li a", :text => "Mastercard")
  end
end
