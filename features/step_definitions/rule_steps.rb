Then /^I should see the following rules?:$/ do |table|
  table.hashes.each do |row_hash|
    row_hash.values.each do |value|
      next if value.to_s.blank?

      page.should have_content(value.to_s)
    end

    rule = Rule.find_by_value(row_hash['value'])
    expected_path = edit_admin_demo_rule_path(rule.demo, rule, :anchor => 'add-rule')
    page.should have_css("a[@href='#{expected_path}']")
  end
end

Then /^I should see the following rules in a form:$/ do |table|
  table.hashes.each do |row_hash|
    suggestible = row_hash.delete('suggestible') == 'true'
    value_field = page.find(:css, "input[@value='#{row_hash['value']}']")
    value_field.should_not be_nil

    enclosing_path = value_field.path + '/ancestor::fieldset'

    within(:xpath, enclosing_path) do
      %w(points reply description alltime_limit referral_points).each do |field_name|
        input_selector = "/input[contains(@name, '[#{field_name}]')]"
        unless row_hash[field_name].blank?
          input_selector += "[@value='#{row_hash[field_name]}']"
        end
        page.should have_xpath(input_selector)
      end

      suggestible_selector = "/input[@type='checkbox']"
      if suggestible
        suggestible_selector += "[@checked='checked']"
      end

      page.should have_xpath(suggestible_selector)
    end
  end
end

Then /^I should not see a rule with the value "([^"]*)" in a form$/ do |value|
  value_field = page.find(:css, "input[@value='#{value}']")
  value_field.should be_nil
end
