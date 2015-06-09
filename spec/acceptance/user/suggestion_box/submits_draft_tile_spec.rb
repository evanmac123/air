require 'acceptance/acceptance_helper'

feature 'Submits/unsubmits tile' do
  let(:user) {FactoryGirl.create(:user, allowed_to_make_tile_suggestions: true)}

  def click_submit_user_draft_tile_button
    page.find('#submit_header a').click
  end
  
  def click_unsubmit_user_draft_tile_button
    page.find('#unsubmit_header a').click
  end

  context "when the tile is not currently submitted" do
    let(:tile) {FactoryGirl.create(:tile, :user_draft, creator: user)}

    it "should change the tile's status to submitted" do
      visit suggested_tile_path(tile.id, as: user)
      click_submit_user_draft_tile_button

      should_be_on suggested_tiles_path
      expect_content "The administrator has been notified that you've submitted a Tile to the Suggestion Box. You'll be notified if your Tile is accepted."
      tile.reload.status.should == Tile::USER_SUBMITTED
    end
  end

  context "when the tile is currently submitted" do
    let(:tile) {FactoryGirl.create(:tile, :user_submitted, creator: user)}

    it "should change the tile's status back to draft" do
      visit suggested_tile_path(tile.id, as: user)
      click_unsubmit_user_draft_tile_button

      should_be_on suggested_tiles_path
      tile.reload.status.should == Tile::USER_DRAFT
      expect_content "You have unsubmitted this Tile. It's now in your Drafts"
    end
  end

  it "lets you click through a tile in the index to get to the show page" do
    draft_tile = FactoryGirl.create(:tile, :user_draft, creator: user)
    submitted_tile = FactoryGirl.create(:tile, :user_submitted, creator: user)

    visit suggested_tiles_path(as: user)
    click_link draft_tile.headline
    should_be_on suggested_tile_path(draft_tile.id)

    visit suggested_tiles_path(as: user)
    click_link submitted_tile.headline
    should_be_on suggested_tile_path(submitted_tile.id)
  end
end
