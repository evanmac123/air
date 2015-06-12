require 'acceptance/acceptance_helper'

feature 'Creates draft tile' do
  let(:user) {FactoryGirl.create(:user, allowed_to_make_tile_suggestions: true)}

  it "should show the user's own drafts, but nobody else's, on an index page" do
    tiles = FactoryGirl.create_list(:tile, 2, :user_drafted, creator: user)
    # And a few that _shouldn't_ appear
    FactoryGirl.create_list(:tile, 3, :user_drafted)
    visit suggested_tiles_path(as: user)
    draft_tab.should have_num_tiles(2)
    tiles.each do |tile|
      expect_content tile.headline
    end
  end

  it "should send ping on index page" do
    visit suggested_tiles_path(as: user)
    expect_ping 'Suggestion Box', {user_action: "Suggestion Box Opened"}, user
  end
  
  it "should link properly from the tile to the appropriate edit page" do
    visit suggested_tiles_path(as: user)
    click_new_tile_placeholder
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
