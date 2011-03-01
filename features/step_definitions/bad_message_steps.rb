Then /^I should see the following bad SMS messages?:$/ do |table|
  with_scope "table#bad_messages" do
    table.hashes.each do |row_hash|
      %w(phone_number message_body received_at).each do |field_name|
        page.should have_content(row_hash[field_name])
      end

      if row_hash['name'].present?
        page.should have_content(row_hash['name'])
      else
        page.should have_content('unknown')
      end
    end
  end
end
