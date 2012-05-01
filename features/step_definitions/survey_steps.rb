Given /^demo "([^"]*)" open survey with name "([^"]*)" exists$/ do |demo_name, survey_name|
  demo = Demo.where(:name => demo_name).first
  demo.should_not be_nil

  FactoryGirl.create :survey, :name => survey_name, :demo => demo, :open_at => Time.now - 6.hours, :close_at => Time.now + 6.hours
end

Given /^demo "([^"]*)" survey with name "([^"]*)" exists$/ do |demo_name, survey_name|
  demo = Demo.where(:name => demo_name).first
  demo.should_not be_nil

  FactoryGirl.create :survey, :name => survey_name, :demo => demo, :open_at => Time.now - 6.hours, :close_at => Time.now - 1.second
end

