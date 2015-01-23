require 'acceptance/acceptance_helper'

feature 'Client admin deletes tile' do
  def delete_tile_link(tile)
    if current_path.include? client_admin_tiles_path
      show_thumbnail_buttons = "$('.tile_buttons').css('display', 'block')"
      page.execute_script show_thumbnail_buttons
    end
    page.find("a[href *= '#{client_admin_tile_path(tile)}'][data-method='delete']")
  end

  def destroy_tile_message
    "Are you sure you want to delete this tile? Deleting a tile is irrevocable and you'll loose all data associated with it."
  end

  def destroy_reveal_selector
    ".confirm-with-reveal"
  end

  before do
    @demo = FactoryGirl.create :demo
    @client_admin = FactoryGirl.create :client_admin, demo: @demo
    @tile = FactoryGirl.create :multiple_choice_tile, demo: @demo
    2.times { FactoryGirl.create :tile_completion, tile: @tile }
  end

  shared_examples_for "deleting a tile" do |page_name|
    before do
      delete_tile_link(@tile).click
    end

    it "should show confirmation pop up", js: true do
      expect_content destroy_tile_message
    end

    it "should change nothing if click cancel", js: true do
      within destroy_reveal_selector do
        page.find(".cancel").click
      end
      expect_no_content destroy_tile_message
      Tile.count.should == 1
      Tile.first.should == @tile
    end

    it "should remove tile if click conform and send ping", js: true do
      within destroy_reveal_selector do
        page.find(".confirm").click
      end

      expect_content "You've successfully deleted the #{@tile.headline} Tile."
      should_be_on client_admin_tiles_path

      Tile.count.should == 0
      TileCompletion.count.should == 0

      expect_ping 'Tile - Deleted', {page: page_name}, @client_admin
    end
  end

  context "on Tile Preview Page" do
    before do
      visit client_admin_tile_path(@tile, as: @client_admin)
    end

    it_should_behave_like "deleting a tile", 'Large Tile Preview'
  end

  context "on Edit Page" do
    before do
      visit client_admin_tiles_path(as: @client_admin)
    end

    it_should_behave_like "deleting a tile", 'Edit'
  end
end