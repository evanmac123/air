require 'acceptance/acceptance_helper'

feature "Sees their accepted tiles" do
  include SuggestionBox

  let(:user) {FactoryGirl.create(:user, allowed_to_make_tile_suggestions: true)}

  shared_examples_for "a read-only view of the tiles" do |section_id, tile_status|
    before do
      @tiles = FactoryGirl.create_list(:tile, 2, creator: user, status: tile_status)
    end

    it "should show them in the index" do
      visit suggested_tiles_path(as: user)

      within section_id do
        @tiles.each do |tile|
          expect_content tile.headline
        end
      end
    end

    it "should allow a preview" do
      @tiles.each do |tile|
        visit suggested_tiles_path(as: user)
        within(section_id) {click_link tile.headline}
        should_be_on suggested_tile_path(tile)
      end
    end

    it "should not allow an unsubmit", js: true do
      visit suggested_tiles_path(as: user)
      show_thumbnail_buttons
      page.should have_no_content("Unsubmit")

      @tiles.each do |tile|
        visit suggested_tile_path(tile, as: user)
        should_be_on suggested_tile_path(tile)
        page.should have_no_css('#unsubmit_header') 
      end
    end

    it "should not allow editing", js: true do
      visit suggested_tiles_path(as: user)
      show_thumbnail_buttons
      page.should have_no_content("Edit")

      @tiles.each do |tile|
        visit suggested_tile_path(tile, as: user)
        should_be_on suggested_tile_path(tile)
        page.should have_no_css('#edit_header') 
      end
    end
  end

  context "in the posted state" do
    it_should_behave_like "a read-only view of the tiles", '#posted_tiles', Tile::ACTIVE
  end

  context "in the archived state" do
    it_should_behave_like "a read-only view of the tiles", '#archived_tiles', Tile::ARCHIVE
  end
end
