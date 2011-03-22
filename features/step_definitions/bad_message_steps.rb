include ActionView::Helpers::DateHelper 

def expect_messages_from_table(table)
  table.hashes.each do |row_hash|
    %w(phone_number message_body).each do |field_name|
      page.should have_content(row_hash[field_name])
    end

    page.should have_content(time_ago_in_words(Time.parse(row_hash['received_at'])))

    if row_hash['name'].present?
      page.should have_content(row_hash['name'])
    else
      page.should have_content('unknown')
    end
  end
end

Given /^the following bad messages with replies exist:$/ do |table|
  table.hashes.each do |row_hash|
    message = Factory :bad_message, :phone_number => row_hash['phone_number'], :body => row_hash['body']
    Factory :bad_message_reply, :bad_message => message, :body => row_hash['reply']
  end
end

When /^I reply to the message "(.*?)"$/ do |body_text|
  message = BadMessage.find_by_body(body_text)
  message.should_not be_nil

  expected_id = "reply-link-#{dom_id(message)}"

  click_link(expected_id)
  fill_in('Say to user:', :with => 'reply text')
  click_button('Send')
end

When /^I dismiss the message "(.*?)"$/ do |body_text|
  message = BadMessage.find_by_body(body_text)
  message.should_not be_nil

  with_scope("form#dismiss-#{dom_id(message)}") { click_button 'Dismiss' }
end

Then /^I should see the following new bad SMS messages?:$/ do |table|
  with_scope '#new-messages' do
    expect_messages_from_table(table)
  end
end

Then /^I should see the following watchlisted bad SMS messages?:$/ do |table|
  with_scope '#watch-listed-messages' do
    expect_messages_from_table(table)
  end
end

Then /^I should see the following messages in the all\-message section:$/ do |table|
  with_scope '#all-messages' do
    expect_messages_from_table(table)
  end
end

Then /^I should see "(.*?)" in the all\-message section$/ do |text|
  with_scope('#all-messages') {page.should have_content(text)}
end

Then /^I should not see any new bad messages$/ do
  with_scope '#new-messages' do
    page.should_not have_css('.message')
  end
end

Then /^I should see a thread:$/ do |table|
  # thread_regexp will match any string that has the contents of the table in 
  # it, with any amount of or no intervening characters, as long as the text
  # from the table appears in the same order in the string as it does in the
  # table.

  thread_regexp = Regexp.new(table.rows.map{|row| Regexp.quote(row.first)}.join('.*'), Regexp::MULTILINE)

  page.body.should match(thread_regexp)
end
