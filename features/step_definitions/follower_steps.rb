include ActionView::Helpers::TextHelper 

def expect_user_details(name, button_type)
  user = User.find_by_name(name)
  user.should_not be_nil

  page.should have_link(user.name)

  page.should have_content("#{user.points} points")
  page.should have_content("fan of " + pluralize(user.following_count, 'person'))
  page.should have_content("has " + pluralize(user.followers_count, 'fan'))

  page.should have_button(button_type.capitalize)
end

def expect_user_friendship_path_button(user, method, text, sense)
  expected_path = user_friendship_path(user)

  main_form_selector = "form[@action='#{expected_path}']" 

  follow_button_selector = "#{main_form_selector} input[@type='submit'][@value='#{text}']"
  
  method_field_selector = if (method.downcase == 'post')
                            nil
                          else
                            "#{main_form_selector} input[@type='hidden'][@name='_method'][@value='#{method}']"
                          end

  if sense
    page.should have_css(follow_button_selector)
    page.should have_css(method_field_selector) if method_field_selector
  else
    page.should have_no_css(follow_button_selector)
  end
end

Given /^"(.*?)" follows "(.*?)"$/ do |follower_name, followed_name|
  follower = User.find_by_name(follower_name)
  followed = User.find_by_name(followed_name)

  Friendship.create(:user => follower, :friend => followed)
end

When /^I unfollow "(.*?)"$/ do |username|
  user = User.find_by_name(username)

  with_scope "##{dom_id(user)}" do
    click_button "De-fan"
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

Then /^I should( not)? see an? (un)?follow button for "(.*?)"$/ do |sense, unfollow_expected, user_name|
  sense = !sense

  user = User.find_by_name(user_name)

  method, text = if unfollow_expected
                   ['delete', 'De-fan']
                 else
                   ['post', 'Be a fan']
                 end

  expect_user_friendship_path_button(user, method, text, sense)
end

