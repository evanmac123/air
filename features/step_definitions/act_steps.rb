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
