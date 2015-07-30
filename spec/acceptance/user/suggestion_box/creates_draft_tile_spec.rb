require 'acceptance/acceptance_helper'

feature 'Creates draft tile' do
  let(:user) {FactoryGirl.create(:user, allowed_to_make_tile_suggestions: true)}

  it "should send ping on index page" do
    visit suggested_tiles_path(as: user)
    expect_ping 'Suggestion Box', {user_action: "Suggestion Box Opened"}, user
  end

  it "should link properly from the tile to the appropriate edit page" do
    visit suggested_tiles_path(as: user)
    click_add_new_tile
    should_be_on new_suggested_tile_path
  end

  it "should let them create and save a draft tile", js: true do
    visit new_suggested_tile_path(as: user)
    create_good_tile
    expect_ping 'Suggestion Box', {user_action: "Tile Created"}, user

    Tile.count.should == 1
    tile = Tile.last
    tile.creator.should == user
    tile.status.should == Tile::USER_SUBMITTED
    
    should_be_on suggested_tile_path(tile.id)
    page.should have_content("The administrator has been notified that you've submitted a Tile to the Suggestion Box. You'll be notified if your Tile is accepted.")
  end
end
