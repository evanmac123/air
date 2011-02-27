When /^I enter the act "(.*?)" via the dropdown$/ do |act_string|
  key_name, value = act_string.split(' ', 2)

  Then "I select \"#{key_name}\" from \"act[key_name]\""
  Then "I select \"#{value}\" from \"act[value]\""
  Then "I press \"add\""
end

When /^I enter the act code "(.*?)"$/ do |act_code|
  Then "I fill in \"act[code]\" with \"#{act_code}\""
  Then "I press \"add\""
end

Then /^I should see the following act(s?):$/ do |_nothing, table|
  table.hashes.each do |act_hash|
    user = User.find_by_name(act_hash['name'])
    expected_user_url = user_path(user)

    within 'ul#acts' do
      within 'li' do
        page.should have_css("a[href='#{expected_user_url}']", :text => user.name)
        page.should have_content(act_hash['act'])
        page.should have_content(act_hash['points'])
      end
    end
  end
end
