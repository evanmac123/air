def expect_user_details(name, button_type)
  user = User.find_by_name(name)
  user.should_not be_nil

  page.should have_link(user.name)

  page.should have_content("#{user.points} points")
  page.should have_content("#{user.following_count} following")
  page.should have_content("#{user.followers_count} followers")

  page.should have_button(button_type.capitalize)
end

When /^I unfollow "(.*?)"$/ do |username|
  user = User.find_by_name(username)

  with_scope "##{dom_id(user)}" do
    click_button "Unfollow"
  end
end

Then /^I should see these followers:$/ do |table|
  with_scope '#followers' do
    table.hashes.each do |row_hash|
      expect_user_details(row_hash['name'], row_hash['button_type'])
    end
  end
end

Then /^I should see these people I am following:$/ do |table|
  with_scope '#followings' do
    table.hashes.each do |row_hash|
      expect_user_details(row_hash['name'], row_hash['button_type'])
    end
  end
end
