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

  # Make sure they're in the right order
  sorted_expected_users = expected_users.sort_by(&:points).reverse

  0.upto(sorted_expected_users.length - 2) do |i|
    first_user = sorted_expected_users[i]
    second_user = sorted_expected_users[i + 1]
    page.body.should match(/#{first_user.name}.*#{second_user.name}/m)
  end
end
