When /^I press the "see more" button in the scoreboard$/ do 
  When %{I press "show-all-ranked-players"}
end

When /^I follow "([^"]*)" in the scoreboard tabs$/ do |text|
  When %{I follow "#{text}" within "#scoreboard-tabs"}
end

Then /^I should see a scoreboard for demo "(.*?)"$/ do |demo_name|

  demo = Demo.find_by_company_name(demo_name)
  expected_users = demo.users.claimed.with_ranking_cutoff
  unexpected_users = User.all - expected_users

  page.should have_content("Scoreboard") 

  with_scope '".top-scores"' do
   expected_users.each do |expected_user|
      expected_path = user_path(expected_user)
      page.should have_css("a[href=\"#{expected_path}\"]", :text => expected_user.name)
      page.should have_content("#{expected_user.points} pts")
    end
  end

  # Make sure they're in the right order
  sorted_expected_users = expected_users.sort_by(&:points).reverse

  0.upto(sorted_expected_users.length - 2) do |i|
    first_user = sorted_expected_users[i]
    second_user = sorted_expected_users[i + 1]
    next if first_user.points == second_user.points

    page.body.should match(/#{first_user.name}.*#{second_user.name}/m)
  end
end

Then /^I should see "(.*?)" with ranking "(.*?)"$/ do |name, ranking|
  with_scope '".top-scores"' do
    page.should have_content("#{ranking} #{name}")
  end
end

Then /^I should not see "(.*?)" in the scoreboard$/ do |name|
  with_scope '".top-scores"' do
    page.should have_no_content(name)
  end
end

Then /^I should see the following user rankings:$/ do |table|
  table.hashes.each {|row_hash| Then "I should see \"#{row_hash['name']}\" with ranking \"#{row_hash['ranking']}\""}
end

Then /^I should see the winning graphic$/ do
  page.should have_css("img[@alt='Img_bluestar_18']")
end

Then /^"([^"]*)" should be the active scoreboard filter link$/ do |link_text|
  find(:css, "#scoreboard-tabs li.active", :text => link_text)
end

