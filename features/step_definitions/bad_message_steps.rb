Given /^the following bad messages with replies exist:$/ do |table|
  table.hashes.each do |row_hash|
    message = Factory :bad_message, :phone_number => row_hash['phone_number'], :body => row_hash['body']
    Factory :bad_message_reply, :bad_message => message, :body => row_hash['reply']
  end
end

Then /^I should see the following bad SMS messages?:$/ do |table|
  table.hashes.each do |row_hash|
    %w(phone_number message_body).each do |field_name|
      page.should have_content(row_hash[field_name])
    end

    page.should have_content(Time.parse(row_hash['received_at']).winning_time_format)

    if row_hash['name'].present?
      page.should have_content(row_hash['name'])
    else
      page.should have_content('unknown')
    end
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
