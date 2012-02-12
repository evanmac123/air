include ActionView::Helpers::TextHelper 

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

  "#{follower.name} has asked to be your fan. Text\n#{expected_request_command} to accept,\n#{expected_ignore_command} to ignore (in which case they won't be notified)"
end

Given /^"(.*?)" follows "(.*?)"$/ do |follower_name, followed_name|
  follower = User.find_by_name(follower_name)
  followed = User.find_by_name(followed_name)

  Friendship.create(:user => follower, :friend => followed)
end

# "When I follow" was taken by web_steps.rb, for links
When /^I fan "(.*?)"$/ do |username|
  pending
  user = User.find_by_name(username)

  with_scope "\"form[@action='/users/#{user.to_param}/friendship']\"" do
    find(:css, '.be-a-fan').click
  end
end

When /^I unfollow "(.*?)"$/ do |username|
  user = User.find_by_name(username)

  with_scope "\"##{dom_id(user)}\"" do
    find(:css, '.defan').click
  end
end

When /^I press the button to see more people I am following$/ do
  page.find(:css, '#fans-of .see-more').click
end

When /^I press the button to see more followers$/ do
  page.find(:css, '#fans .see-more').click
end

When /^I press the accept button$/ do
  find(:css, "#pending-followers input.accept").click
end

When /^I press the ignore button$/ do
  find(:css, "#pending-followers input.ignore").click
end

When /^"([^"]*)" requests to follow "([^"]*)" by SMS$/ do |follower_name, followed_login_string|
  followed_name, followed_password = split_login_string(followed_login_string)

  follower = User.find_by_name(follower_name)
  followed = User.find_by_name(followed_name)

  When "\"#{follower.phone_number}\" sends SMS \"follow #{followed.sms_slug}\""
  And "DJ cranks 5 times"
  Then "\"#{follower.phone_number}\" should have received an SMS \"OK, you'll be a fan of #{followed.name}, pending their acceptance.\""
  And "I sign in via the login page with \"#{followed_login_string}\""
  And "I should not see \"#{follower.name}\" as a follower"
  But "I should see \"#{follower.name}\" as a pending follower"
end

When /^"([^"]*)" requests to follow "([^"]*)" by web$/ do |follower_login_string, followed_login_string|
  pending
  follower_name, follower_password = split_login_string(follower_login_string)
  followed_name, followed_password = split_login_string(followed_login_string)

  When "I sign in via the login page as \"#{follower_login_string}\""
  And "I go to the profile page for \"#{followed_name}\""
  And "I fan \"#{followed_name}\""
  Then "I should see \"OK, you'll be a fan of #{followed_name}, pending their acceptance.\""
  But "I should see \"fan of Bob\" just once"

  When "I sign in via the login page as \"#{followed_login_string}\""
  Then "I should see \"#{follower_name}\" as a pending follower"
  But "I should not see \"#{follower_name}\" as a follower"
end

When /^I select the "([^"]*)" notification setting$/ do |notification_value|
  When "I choose \"#{notification_value}\" within \".notification-method\""
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

Then /^"(.*?)" should not be able to follow "([^"]*)"$/ do |follower, followed|
  followed_user = User.find_by_name(followed)
  follower_user = User.find_by_name(follower)

  #When "I go to the profile page for \"#{followed}\""
  #And "I fan \"#{followed}\""
  #And "\"#{followed_user.phone_number}\" sends SMS \"accept #{follower_user.sms_slug}\""
  And "I go to the user directory page"
  And "I fan \"#{followed}\""
  And "\"#{followed_user.phone_number}\" sends SMS \"accept #{follower_user.sms_slug}\""
  And "I go to the friends page"
  And "I fan \"#{followed}\""
  And "\"#{followed_user.phone_number}\" sends SMS \"accept #{follower_user.sms_slug}\""
  And "I go to the activity page"
  Then "I should not see \"#{follower} is now a fan of #{followed}\""
end

Then /^all follow buttons for "(.*?)" should be disabled$/ do |username|
  When "I go to the profile page for \"#{username}\""
  Then 'all follow buttons on the page should be disabled'
  When 'I go to the user directory page'
  Then 'all follow buttons on the page should be disabled'
  When 'I go to the friends page'
  Then 'all follow buttons on the page should be disabled'
end

Then /^I should( not)? see "([^"]*)" as a follower$/ do |sense, username|
  sense = !sense

  When "I go to the connections page"
  with_scope '"#followers"' do
    if sense
      page.should have_content(username)
    else
      page.should have_no_content(username)
    end
  end
end

Then /^I should( not)? see "([^"]*)" as a person I'm following$/ do |sense, username|
  sense = !sense

  When "I go to the connections page"
  with_scope '"#fans-of"' do
    if sense
      page.should have_content(username)
    else
      page.should have_no_content(username)
    end
  end
end

Then /^I should( not)? see "([^"]*)" as a pending follower$/ do |sense, username|
  sense = !sense

  When "I go to the connections page"

  unless page.all(:css, '#pending-followers').empty? && !sense
    with_scope '"#pending-followers"' do
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

  Then "\"#{followed.phone_number}\" should have received an SMS \"#{expected_request_text(follower, request_index)}\""
  When "\"#{followed.phone_number}\" sends SMS \"#{acceptance_string}\""
  And "DJ cranks 5 times"
  Then "\"#{follower.phone_number}\" should have received an SMS \"#{followed_name} has approved your request to be a fan.\""
  And "\"#{followed.phone_number}\" should have received an SMS \"OK, #{follower.name} is now your fan.\""
  When "I sign in via the login page with \"#{followed_login_string}\""
  Then "I should see \"#{follower_name}\" as a follower"
  But "I should not see \"#{follower_name}\" as a pending follower"
end

Then /^"([^"]*)" should be able to ignore "([^"]*)" by SMS( with index \d+)?$/ do |followed_login_string, follower_name, request_index_string|
  followed_name, followed_password = split_login_string(followed_login_string)

  followed = User.find_by_name(followed_name)
  follower = User.find_by_name(follower_name)

  request_index = request_index_string.present? ? request_index_string.split.last : nil

  rejection_string = request_index ? "no #{request_index}" : "no"

  Then "\"#{followed.phone_number}\" should have received an SMS \"#{expected_request_text(follower, request_index)}\""
  When "\"#{followed.phone_number}\" sends SMS \"#{rejection_string}\""
  Then "\"#{followed.phone_number}\" should have received an SMS \"OK, we'll ignore the request from #{follower.name} to be your fan.\""
  When "I sign in via the login page with \"#{followed_login_string}\""
  And "I should not see \"#{follower.name}\" as a follower"
  And "I should not see \"#{follower.name}\" as a pending follower"
end

Then /^"([^"]*)" should be able to accept "([^"]*)" by web$/ do |followed_login_string, follower_name|
  followed_name, followed_password = split_login_string(followed_login_string)

  followed = User.find_by_name(followed_name)
  follower = User.find_by_name(follower_name)

  When "I sign in via the login page with \"#{followed_login_string}\""
  When "I go to the connections page"
  And "I press the accept button"
  And "DJ cranks 5 times"
  Then "\"#{follower.phone_number}\" should have received an SMS \"#{followed_name} has approved your request to be a fan.\""
  And "I should see \"OK, #{follower_name} is now your fan.\""
  And "I should see \"#{follower_name}\" as a follower"
  But "I should not see \"#{follower_name}\" as a pending follower"
end

Then /^"([^"]*)" should be able to ignore "([^"]*)" by web$/ do |followed_login_string, follower_name|
  When "I sign in via the login page with \"#{followed_login_string}\""
  When "I go to the connections page"
  And "I press the ignore button"
  Then "I should see \"OK, we'll ignore the request from #{follower_name} to be your fan.\""
  And "I should not see \"#{follower_name}\" as a follower"
  And "I should not see \"#{follower_name}\" as a pending follower"
end

Then /^"([^"]*)" should have received a follow notification email about "([^"]*)"( with phone number "(.*?)")?$/ do |address, follower_name, _nothing, phone_number|
  phone_number ||= TWILIO_PHONE_NUMBER.as_pretty_phone

  When "\"#{address}\" opens the email with subject \"#{follower_name} wants to be your fan on H Engage\""

  Then %{they should see "YES" in the email body}
  And %{they should see "NO" in the email body}
  #And "they click the first link in the email"
  #Then "they should see \"#{phone_number}\" in the email body"
  #Then "I should be on the connections page"
end
