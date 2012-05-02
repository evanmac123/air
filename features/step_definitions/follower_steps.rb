include ActionView::Helpers::TextHelper 

# TODO: Fix this mess.

def expect_user_details(name, button_type)
  user = User.find_by_name(name)
  user.should_not be_nil

  with_scope "\"##{dom_id(user)}\"" do
    page.should have_link(user.name)

    page.should have_content("#{user.points} pts")
    page.should have_content("Fan of " + pluralize(user.accepted_friends.count, 'person'))
    page.should have_content("Has " + pluralize(user.accepted_followers.count, 'fan'))

    case button_type
    when 'be a fan'
      page.should have_css('.be-a-fan')
    when 'de-fan'
      page.should have_css('.defan')
    end
  end
end

def expect_user_friendship_path_button(user, method, dom_class, sense)
  expected_path = user_friendship_path(user)
  submit_form = "form[@action='#{expected_path}']" 

  div_containing_submit_form = ".#{dom_class} #{submit_form}"

  if sense
    page.should have_css(div_containing_submit_form)
  else
    page.should have_no_css(div_containing_submit_form)
  end
end

def split_login_string(login_string)
  login_string.split(/\//)
end

def expected_request_text(follower, request_index)
  expected_request_command = request_index ? "YES #{request_index}" : "YES"
  expected_ignore_command = request_index ? "NO #{request_index}" : "NO"

  "#{follower.name} has asked to be your friend. Text\n#{expected_request_command} to accept,\n#{expected_ignore_command} to quietly ignore"
end

Given /^"(.*?)" follows "(.*?)"$/ do |follower_name, followed_name|
  follower = User.find_by_name(follower_name)
  followed = User.find_by_name(followed_name)

  Friendship.create(:user => follower, :friend => followed)
end

# "When I follow" was taken by web_steps.rb, for links
When /^I find and request to be friends with "(.*?)"$/ do |username|
  step "I go to the user directory page"
  step %{I fill in "search bar" with "#{username}"}
  step %{I press "Find!"}
  step %{I press the befriend button for "#{username}"}
end

When /^I press the befriend button for "(.*?)"$/ do |username|
  user = User.find_by_name(username)
  form_path = %{form[action="/users/#{user.to_param}/friendship"]}
  page.execute_script("$('#{form_path}').submit()")
end

When /^I unfollow "(.*?)"$/ do |username|
  user = User.find_by_name(username)
  form_path = %{form[action="/users/#{user.slug}/friendship"]}
  page.execute_script("$('#{form_path}').submit()")
end

When /^I press the button to see more people I am following$/ do
  page.find(:css, '#fans-of .see-more').click
end

When /^I press the button to see more followers$/ do
  page.find(:css, '#fans .see-more').click
end

When /^I press the accept button$/ do
  find(:css, ".follow-btn").click
end

When /^I press the ignore button$/ do
  find(:css, "#pending-followers input.ignore").click
end

When /^"([^"]*)" befriends "([^"]*)" by SMS$/ do |follower_name, followed_login_string|
  followed_name, followed_password = split_login_string(followed_login_string)

  follower = User.find_by_name(follower_name)
  followed = User.find_by_name(followed_name)

  step "\"#{follower.phone_number}\" sends SMS \"follow #{followed.sms_slug}\""
  step "DJ cranks 5 times"
  step "\"#{follower.phone_number}\" should have received an SMS \"OK, you'll be friends with #{followed.name}, pending their acceptance.\""
  step "I sign in via the login page with \"#{followed_login_string}\""
  step %{I go to the profile page for "#{followed_name}"}
  step "I should not see \"#{follower.name}\" as a friend"
end

When /^"([^"]*)" befriends "([^"]*)" by web$/ do |follower_login_string, followed_login_string|
  follower_name, follower_password = split_login_string(follower_login_string)
  followed_name, followed_password = split_login_string(followed_login_string)

  step "I sign in via the login page as \"#{follower_login_string}\""
  step "I go to the profile page for \"#{followed_name}\""
  step "I click within \".follow-btn\""
  step "I should see \"OK, you'll be friends with #{followed_name}, pending their acceptance.\""
  step "I should see \"friendship requested\" just once"
end

When /^I select the "([^"]*)" notification setting$/ do |notification_value|
  step "I choose \"#{notification_value}\" within \".notification-method\""
end

Then /^I should see these followers:$/ do |table|
  with_scope '"#followers"' do
    table.hashes.each do |row_hash|
      expect_user_details(row_hash['name'], row_hash['button_type'])
    end
  end
end

Then /^I should see these people I am following:$/ do |table|
  with_scope '"#followings"' do
    table.hashes.each do |row_hash|
      expect_user_details(row_hash['name'], row_hash['button_type'])
    end
  end
end

Then /^I should( not)? see an? (un)?follow button for "(.*?)"$/ do |sense, unfollow_expected, user_name|
  sense = !sense

  user = User.find_by_name(user_name)

  method, dom_class = if unfollow_expected
                   ['delete', 'stop-following-btn']
                 else
                   ['post', 'follow-btn']
                 end

  expect_user_friendship_path_button(user, method, dom_class, sense)
end

Then /^all follow buttons on the page should be disabled$/ do
  page.all(:css, 'input.be-a-fan').each{|follow_button| follow_button['disabled'].should be_present}
end

Then /^all follow buttons for "(.*?)" should be disabled$/ do |username|
  step "I go to the profile page for \"#{username}\""
  step 'all follow buttons on the page should be disabled'
  step 'I go to the user directory page'
  step 'all follow buttons on the page should be disabled'
end

Then /^I should( not)? see "([^"]*)" as a friend$/ do |sense, username|
  sense = !sense
  with_scope '"#accepted_friendships"' do
    if sense
      page.should have_content(username)
    else
      page.should have_no_content(username)
    end
  end
end

Then /^I should( not)? see a friendship request from "([^"]*)"$/ do |sense, username|
  sense = !sense

  step "I follow \"My Profile\""

  unless page.all(:css, '#friend_requests').empty? && !sense
    with_scope '"#friend_requests"' do
      if sense
        page.should have_content(username)
      else
        page.should have_no_content(username)
      end
    end
  end
end

Then /^"([^"]*)" should be able to accept "([^"]*)" by SMS( with index \d+)?$/ do |followed_login_string, follower_name, request_index_string|
  followed_name, followed_password = split_login_string(followed_login_string)

  followed = User.find_by_name(followed_name)
  follower = User.find_by_name(follower_name)

  request_index = request_index_string.present? ? request_index_string.split.last : nil
  acceptance_string = request_index ? "yes #{request_index}" : "yes"
  step "\"#{followed.phone_number}\" should have received an SMS \"#{expected_request_text(follower, request_index)}\""
  step "\"#{followed.phone_number}\" sends SMS \"#{acceptance_string}\""
  step "DJ cranks 5 times"
  step "\"#{follower.phone_number}\" should have received an SMS \"#{followed_name} has approved your friendship request.\""
  step "\"#{followed.phone_number}\" should have received an SMS \"OK, you are now friends with #{follower.name}.\""
  step "I sign in via the login page with \"#{followed_login_string}\""
  step %{I go to the profile page for "#{followed_name}"}
  step "I should see \"#{follower_name}\" as a friend"
  #step "I should not see \"#{follower_name}\" as a pending follower"
end

Then /^"([^"]*)" should be able to ignore "([^"]*)" by SMS( with index \d+)?$/ do |followed_login_string, follower_name, request_index_string|
  followed_name, followed_password = split_login_string(followed_login_string)

  followed = User.find_by_name(followed_name)
  follower = User.find_by_name(follower_name)

  request_index = request_index_string.present? ? request_index_string.split.last : nil

  rejection_string = request_index ? "no #{request_index}" : "no"

  step "\"#{followed.phone_number}\" should have received an SMS \"#{expected_request_text(follower, request_index)}\""
  step "\"#{followed.phone_number}\" sends SMS \"#{rejection_string}\""
  step "\"#{followed.phone_number}\" should have received an SMS \"OK, we'll ignore the request from #{follower.name} to be your friend.\""
  step "I sign in via the login page with \"#{followed_login_string}\""
  step %{I go to the profile page for "#{followed_name}"}
  step "I should not see \"#{follower.name}\" as a friend"
  #And "I should not see \"#{follower.name}\" as a pending follower"
end

Then /^"([^"]*)" should be able to accept "([^"]*)" by web$/ do |followed_login_string, follower_name|
  followed_name, followed_password = split_login_string(followed_login_string)

  followed = User.find_by_name(followed_name)
  follower = User.find_by_name(follower_name)

  step "I sign in via the login page with \"#{followed_login_string}\""
  step "I go to the user page for \"#{follower.name}\""
  
  step "I press the button next to \"#{follower_name}\""
  step "DJ cranks 5 times"
  step "I dump all sent texts"
  step "\"#{follower.phone_number}\" should have received an SMS \"#{followed_name} has approved your friendship request.\""
  step "I should see \"You are now friends with #{follower_name}\""
  step "I should see \"#{followed_name}\" as a friend"
  step "I should not see a friendship request from \"#{follower_name}\""
end

Then /^"([^"]*)" should be able to ignore "([^"]*)" by web$/ do |followed_login_string, follower_name|
  step "I sign in via the login page with \"#{followed_login_string}\""
  step "I go to the connections page"
  step "I press the ignore button"
  step "I should see \"OK, we'll ignore the request from #{follower_name} to be your fan.\""
  step "I should not see \"#{follower_name}\" as a friend"
  step "I should not see \"#{follower_name}\" as a pending follower"
end

Then /^"([^"]*)" should have received a follow notification email about "([^"]*)"( with phone number "(.*?)")?$/ do |address, follower_name, _nothing, phone_number|
  phone_number ||= TWILIO_PHONE_NUMBER.as_pretty_phone

  step "\"#{address}\" opens the email with subject \"#{follower_name} wants to be your friend on H Engage\""

  step %{they should see "YES" in the email body}
  step %{they should see "NO" in the email body}
  #And "they click the first link in the email"
  #Then "they should see \"#{phone_number}\" in the email body"
  #Then "I should be on the connections page"
end

Then /^I should see (\d+) (person|people) being followed$/ do |count, _nothing|
  page.all(:css, "#friends_list .user-name").count.should == count.to_i
end

Then /^I should see (\d+) followers?$/ do |count|
  page.all(:css, "#followed-by .user-name").count.should == count.to_i
end

Given /^I press the button next to "([^"]*)"$/ do |name|
  slug = User.find_by_name(name).sms_slug
  id = "update_friendship_with_" + slug
  click_button(id)
end

Then /^"([^"]*)" accepts "([^"]*)" as a friend$/ do |accepter_name, initiator_name|
  initiator_id = User.find_by_name(initiator_name)
  accepter_id = User.find_by_name(accepter_name)
  friendship = Friendship.where(:friend_id => accepter_id, :user_id => initiator_id).first
  friendship.accept.should_not be_nil
end

When /^I press the invite button for "([^"]*)"$/ do |name|
  user = User.find_by_name(name)
  submit_id_with_pound = "#invite_" + user.slug
  find(:css, submit_id_with_pound).click
end