def user_suggestions(user_name, tile_name)
  user = User.where(:name => user_name).first
  tile = Tile.where(:name => tile_name).first
  TileCompletion.where(:user_id => user.id, :tile_id => tile.id)
end

Given /^"([^"]*)" has completed tile "([^"]*)"$/ do |user_name, tile_name|
  suggestions = user_suggestions(user_name, tile_name)
  suggestions.should_not be_empty
  suggestions.each(&:satisfy!)
end

Given /^"([^"]*)" has not had tile "([^"]*)" suggested$/ do |user_name, tile_name|
  user_suggestions(user_name, tile_name).each(&:destroy)
end

When /^I enter "([^"]*)" into the bonus points field$/ do |arg1|
  page.fill_in(:tile_bonus_points, :with => arg1)
end

When /^I click "([^"]*)"$/ do |arg1|
  page.click_button(:tile_submit)
end

Given /^the tile "([^"]*)" has prerequisite "([^"]*)"$/ do |tile_name, prerequisite_name|
  tile = Tile.where(:name => tile_name).first
  prerequisite = Tile.where(:name => prerequisite_name).first

  unless tile
    raise ArgumentError.new "Couldn't find tile named #{tile_name}"
  end

  unless prerequisite
    raise ArgumentError.new "Couldn't find prerequisite tile named #{prerequisite_name}"
  end

  tile.prerequisite_tiles << prerequisite
end

When /^I set the tile start time to "([^"]*)"$/ do |time_string|
  set_time_inputs("tile_start_time", time_string)
end

When /^I click the link to edit the tile "([^"]*)"$/ do |tile_name|
  tile_name_cell = page.find('td', :text => tile_name)
  tile_row_path = tile_name_cell.path + '/..'
  within(:xpath, tile_row_path) {click_link "Edit this tile"}
end

When /^"([^"]*)" satisfies tile "([^"]*)"$/ do |user_name, tile_name|
  user = User.find_by_name(user_name)
  tile = Tile.find_by_name(tile_name)
  tile.satisfy_for_user!(user)
end
