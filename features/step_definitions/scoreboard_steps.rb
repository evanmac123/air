Then /^I should see a scoreboard$/ do
  page.should have_content("Top users")
  top_users = User.top(5)

  with_scope '#top-users' do
    top_users.each do |top_user|
      expected_path = user_path(top_user)
      page.should have_css("a[href=\"#{expected_path}\"]", :text => top_user.name)
      page.should have_content("#{top_user.points} points")
    end
  end
end
