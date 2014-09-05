def expect_rule_rows(rule_or_hash)
  primary_value, secondary_values = (rule_or_hash.respond_to?(:primary_value)) ?
    [rule_or_hash.primary_value.value, rule_or_hash.secondary_values.map(&:value)] :
    [rule_or_hash['primary_value'], rule_or_hash['secondary_values'].split(',')]

  primary_value_cell = page.find(:css, 'td', :text => primary_value)
  primary_value_cell.should_not be_nil, "Found no rule row for \"#{primary_value}\""

  main_rule_row = primary_value_cell.find(:xpath, '..')
  cell_path = main_rule_row.path + "/td"

  %w(points reply description alltime_limit referral_points suggestible).each do |field_name|
    expected_value = rule_or_hash[field_name].to_s
    page.find(:xpath, cell_path, :text => expected_value).should_not be_nil, "Found no cell containing #{field_name} (expected value \"#{expected_value}\")"
  end

  secondary_values_cell_path = main_rule_row.path + "/following-sibling::tr/td"
  secondary_values.each do |secondary_value|
    page.find(:xpath, secondary_values_cell_path, :text => secondary_value).should_not be_nil, "Didn't find secondary value \"#{secondary_value}\""
  end
end

When /^I fill in secondary value field \#(\d+) with "([^"]*)"$/ do |index_plus_one, value|
  index = index_plus_one.to_i - 1
  field_name = "rule[secondary_values][#{index}]"
  fill_in field_name, :with => value
end

Then /^I should see the following rules?:$/ do |table|
  table.hashes.each {|row_hash| expect_rule_rows(row_hash)}
end

Then /^I should see all the standard rulebook rules$/ do
  Rule.where(:demo_id => nil).each do |rule|
    expect_rule_rows(rule)
  end
end

When /^I check the "([^"]*)" tag$/ do |arg1|
  page.check(arg1)
end

Then /^the radio button for "([^"]*)" should be checked$/ do |arg1|

  id_of_primary_tag = Tag.find_by_name(arg1).id

  page.find(:css, "#rule_primary_tag_id_#{id_of_primary_tag}")
end

When /^I click the "(.*)" button for value "(.*)"$/ do |button, value|
  find("input[value = '#{button}'][data-value-text = '#{value}']").click
end
