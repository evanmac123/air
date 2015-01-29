Then /^I should see the success message "(.*)"$/ do |message|
  with_scope '"#flash_success"' do
    page.should have_content(message)
  end
end

Then /^I should see the error "(.*)"$/ do |message|
  with_scope '"#flash_failure"' do
    page.should have_content(message)
  end
end

Then /^there should be a mail link to support in the flash$/ do
  find(:css, %{#flash a[@href="mailto:support@airbo.com"]}).should_not be_nil
end

