require 'acceptance/acceptance_helper'

feature 'Client admin gets limited access by token' do
  let(:client_admin) {FactoryGirl.create(:client_admin)}

  scenario "to the explore page, when the token is appended as a query parameter" do
    visit explore_path(explore_token: client_admin.explore_token)

    should_be_on explore_path
  end

  scenario "to the tile tag page, when the token is appended as a query parameter" do
    tile_tag = FactoryGirl.create(:tile_tag)
    visit tile_tag_show_explore_path(tile_tag: tile_tag, explore_token: client_admin.explore_token)

    should_be_on tile_tag_show_explore_path
  end

  scenario "when they log in by token in a query parameter, they don't have to keep appending it in subsequent requests" do
    tile_tag = FactoryGirl.create(:tile_tag)

    visit explore_path(explore_token: client_admin.explore_token)
    visit tile_tag_show_explore_path(tile_tag: tile_tag)

    should_be_on tile_tag_show_explore_path
  end

  scenario "can't go outside the explore family using a token in the query parameter" do
    visit activity_path(explore_token: client_admin.explore_token)
    should_be_on sign_in_path
  end

  scenario "can't go outside the explore family using a token in the session" do
    visit explore_path(explore_token: client_admin.explore_token)
    visit activity_path(explore_token: client_admin.explore_token)
    should_be_on sign_in_path
  end
end
