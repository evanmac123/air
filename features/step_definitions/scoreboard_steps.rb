Then /^I should see a scoreboard for demo "(.*?)"$/ do |demo_name|

  demo = Demo.find_by_company_name(demo_name)
  expected_users = demo.users
  unexpected_users = User.all - expected_users

  page.should have_content("Top users") 

  with_scope '#top-users' do
    expected_users.each do |expected_user|
      expected_path = user_path(expected_user)
      page.should have_css("a[href=\"#{expected_path}\"]", :text => expected_user.name)
      page.should have_content("#{expected_user.points} points")
    end
  end
end
