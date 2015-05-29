require 'acceptance/acceptance_helper'

feature 'Client Admin uses menu on tile preview page of suggested tile' do
  include WaitForAjax
  include SuggestionBox

  let!(:demo) { FactoryGirl.create :demo }
  let!(:client_admin) { FactoryGirl.create :client_admin, demo: demo }

  def menu_header
    page.find(".preview_menu_header")
  end

  def menu_items
    page.all(".preview_menu_item .header_text")
  end

  context "submitted tile" do
    let!(:tile) { FactoryGirl.create :multiple_choice_tile, :user_submitted, demo: demo }

    before do
      visit client_admin_tile_path(tile, as: client_admin)
    end

    it "should have right menu header" do
      menu_header.text.should == "Submitted"
    end

    it "should have right menu items" do
      menu_items.map(&:text).should == ["Back to Tiles", "Accept", "Ignore"]
    end

    context "Back to Tiles link" do
      it "should move user to suggestion box" do
        click_link "Back to Tiles"
        current_path.should == client_admin_tiles_path
        page.find(".suggestion_box_selected").should be_present
        headline(page.find(:tile, tile)).should == tile.headline
      end
    end

    context "Accept Link" do
      before do 
        click_link "Accept"
        # moved to draft section on tile manager page
        current_path.should == client_admin_tiles_path
        page.find(".draft_selected").should be_present
        # sees accept modal
        expect_content accept_modal_copy
        tile.reload.status.should == Tile::DRAFT
      end

      scenario "accepts tile", js: true do
        click_link "Got it"
        expect_no_content accept_modal_copy
        visible_tiles.count.should == 1
        headline(page.find(:tile, tile)).should == headline(visible_tiles[0])
      end

      scenario "undoes accepting", js: true do
        click_link "Undo"
        expect_no_content accept_modal_copy
        sleep 1
        wait_for_ajax
        current_path.should == client_admin_tile_path(tile)
        menu_header.text.should == "Submitted"
        tile.reload.status.should == Tile::USER_SUBMITTED
      end
    end

    context "Ignore Link" do
      it "should ignore tile" do
        click_link "Ignore"
        expect_content "The #{tile.headline} tile has been ignored"
        menu_header.text.should == "Ignored"
        tile.reload.status.should == Tile::IGNORED
      end
    end
  end
end
