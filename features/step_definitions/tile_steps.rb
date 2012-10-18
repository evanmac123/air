def user_suggestions(user_name, tile_headline)
  user = User.where(:name => user_name).first
  tile = Tile.where(:headline => tile_headline).first
  TileCompletion.where(:user_id => user.id, :tile_id => tile.id)
end

Given /^"([^"]*)" has completed tile "([^"]*)"$/ do |user_name, tile_headline|
  suggestions = user_suggestions(user_name, tile_headline)
  suggestions.should_not be_empty
  suggestions.each(&:satisfy!)
end

Given /^"([^"]*)" has not had tile "([^"]*)" suggested$/ do |user_name, tile_headline|
  user_suggestions(user_name, tile_headline).each(&:destroy)
end

When /^I enter "([^"]*)" into the bonus points field$/ do |arg1|
  page.fill_in(:tile_bonus_points, :with => arg1)
end

When /^I click "([^"]*)"$/ do |arg1|
  page.click_button(:tile_submit)
end

Given /^the tile "([^"]*)" has prerequisite "([^"]*)"$/ do |tile_headline, prerequisite_headline|
  tile = Tile.where(:headline => tile_headline).first
  prerequisite = Tile.where(:headline => prerequisite_headline).first

  unless tile
    raise ArgumentError.new "Couldn't find tile named #{tile_headline}"
  end

  unless prerequisite
    raise ArgumentError.new "Couldn't find prerequisite tile named #{prerequisite_headline}"
  end

  tile.prerequisite_tiles << prerequisite
end

When /^I set the tile start time to "([^"]*)"$/ do |time_string|
  set_time_inputs("tile_start_time", time_string)
end

When /^I click the link to edit the tile "([^"]*)"$/ do |tile_headline|
  tile_headline_cell = page.find('td', :text => tile_headline)
  tile_row_path = tile_headline_cell.path + '/..'
  within(:xpath, tile_row_path) {click_link "Edit this tile"}
end

When /^"([^"]*)" satisfies tile "([^"]*)"$/ do |user_name, tile_headline|
  user = User.find_by_name(user_name)
  tile = Tile.find_by_headline(tile_headline)
  tile.satisfy_for_user!(user)
end

When /^I attach an image to the tile$/ do
  attach_file "tile[image]", tile_fixture_path('cov1.jpg')
end

When /^I attach a thumbnail to the tile$/ do
  attach_file "tile[thumbnail]", tile_fixture_path('cov1_thumbnail.jpg')
end
