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

  def intro_tooltip
    page.find(".tile_preview_intro")
  end

  def intro_text
    "Accept the tile to use it in your Board, or Ignore it to mark it as reviewed."
  end

  context "Intro For Submitted Tile" do
    let!(:tile) { FactoryGirl.create :multiple_choice_tile, :user_submitted, demo: demo }

    before do
      client_admin.update_attribute(:submitted_tile_menu_intro_seen, false)
      visit client_admin_tile_path(tile, as: client_admin)
    end

    it "should show intro first time", js: true do
      intro_tooltip.should be_present
      expect_content intro_text
      click_link "Got it"
      expect_no_content intro_text
      visit client_admin_tile_path(tile, as: client_admin)
      expect_no_content intro_text
    end
  end

  context "Submitted Tile" do
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

  context "Ignored Tile" do
    let!(:tile) { FactoryGirl.create :multiple_choice_tile, :ignored, demo: demo }

    before do
      visit client_admin_tile_path(tile, as: client_admin)
    end

    it "should have right menu header" do
      menu_header.text.should == "Ignored"
    end

    it "should have right menu items" do
      menu_items.map(&:text).should == ["Back to Tiles", "Undo Ignore"]
    end

    context "Back to Tiles link" do
      it "should move user to suggestion box" do
        click_link "Back to Tiles"
        current_path.should == client_admin_tiles_path
        page.find(".suggestion_box_selected").should be_present
        headline(page.find(:tile, tile)).should == tile.headline
      end
    end

    context "Undo Ignore Link" do
      it "should make tile submitted" do
        click_link "Undo Ignore"
        expect_content "The #{tile.headline} tile has been moved to submitted"
        menu_header.text.should == "Submitted"
        tile.reload.status.should == Tile::USER_SUBMITTED
      end
    end
  end
end
