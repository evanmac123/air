require 'acceptance/acceptance_helper'

feature 'Submits/unsubmits tile' do
  include SuggestionBox

  let(:user) {FactoryGirl.create(:user, allowed_to_make_tile_suggestions: true)}
  let(:tile) {FactoryGirl.create(:tile, :user_draft, creator: user)}

  def click_submit_user_draft_tile_button
    page.find('#submit_header a').click
  end
  
  def click_unsubmit_user_draft_tile_button
    page.find('#unsubmit_header a').click
  end

  def expect_tile_submitted(tile)
    should_be_on suggested_tiles_path
    expect_content "The administrator has been notified that you've submitted a Tile to the Suggestion Box. You'll be notified if your Tile is accepted."
    tile.reload.status.should == Tile::USER_SUBMITTED
  end

  def expect_tile_unsubmitted(tile)
    should_be_on suggested_tiles_path
    tile.reload.status.should == Tile::USER_DRAFT
    expect_content "You have unsubmitted this Tile. It's now in your Drafts"
  end

  context "through the full-size preview" do
    context "when the tile is not currently submitted" do
      it "should change the tile's status to submitted" do
        visit suggested_tile_path(tile.id, as: user)
        click_submit_user_draft_tile_button
        expect_tile_submitted(tile)
      end
    end

    context "when the tile is currently submitted" do
      let(:tile) {FactoryGirl.create(:tile, :user_submitted, creator: user)}

      it "should change the tile's status back to draft" do
        visit suggested_tile_path(tile.id, as: user)
        click_unsubmit_user_draft_tile_button
        expect_tile_unsubmitted(tile)
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

  context "from the suggestion box index" do
    context "when the tile is not submitted" do
      before do
        # This apparent no-op is here due to the interaction between 
        # Poltergeist and lazy creation via let(). It ensures that tile is 
        # visisible from within Poltergeist's thread.

        tile
      end

      it "should have a submit button that works", js: true do
        visit suggested_tiles_path(as: user)
        submit_tile_button(tile).click
        expect_tile_submitted(tile)
      end

      it "should have no unsubmit button", js: true do
        visit suggested_tiles_path(as: user)
        show_thumbnail_buttons

        page.should have_no_css(unsubmit_tile_selector(tile))
      end
    end

    context "when the tile is submitted" do
      before do
        tile.status = Tile::USER_SUBMITTED
        tile.save!
      end

      it "should have an unsubmit button that works", js: true do
        visit suggested_tiles_path(as: user)
        unsubmit_button(tile).click
        expect_tile_unsubmitted(tile)
      end

      it "should have no submit button", js: true do
        visit suggested_tiles_path(as: user)
        show_thumbnail_buttons
        page.should have_no_css(submit_tile_selector(tile))
      end
    end
  end
end
