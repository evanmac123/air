require 'acceptance/acceptance_helper'

feature 'Client accepts suggested tile' do
  include WaitForAjax

  let!(:admin) { FactoryGirl.create :client_admin }
  let!(:demo)  { admin.demo  }
  let!(:submitted_tiles) { FactoryGirl.create_list :multiple_choice_tile, 3, :user_submitted, demo: demo }

  def tile_selector
    ".tile_container:not(.placeholder_container) .tile_thumbnail"
  end

  def visible_tiles
    page.all(tile_selector, visible: true)
  end

  def suggestion_box_title
    page.find("#suggestion_box_title")
  end

  def draft_title
    page.find("#draft_title")
  end

  def accept_button tile
    show_thumbnail_buttons = "$('.tile_buttons').css('display', 'block')"
    page.execute_script show_thumbnail_buttons

    page.find("a[href *= '#{client_admin_tile_path(tile, update_status: Tile::DRAFT)}']")
  end

  def accept_modal
    page.find("#accept-tile-modal")
  end

  def accept_modal_copy
    "Tile Accepted and Moved to Draft"
  end

  def headline tile
    within tile do
      page.find(".headline .text").text
    end
  end

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  before do
    FactoryGirl.create :multiple_choice_tile, :draft, demo: demo
  end

  scenario "switches between drafts and suggestion box", js: true do
    visit client_admin_tiles_path
    # in draft section
    visible_tiles.count.should == 1
    suggestion_box_title.click
    # in suggestion box
    visible_tiles.count.should == 3
    draft_title.click
    # and again in draft section
    visible_tiles.count.should == 1
  end

  context "suggestion box" do
    before do
      visit client_admin_tiles_path(showSuggestionBox: true)

      @tile = submitted_tiles[1]
      accept_button(@tile).click
      expect_content accept_modal_copy
    end

    scenario "accepts tile", js: true do
      click_link "Got it"
      visible_tiles.count.should == 2
      wait_for_ajax
      draft_title.click
      sleep 1
      visible_tiles.count.should == 2
      headline(page.find(:tile, @tile)).should == headline(visible_tiles[0])
    end

    scenario "clicks 'accept', then 'undo' action", js: true do
      page.find(".undo").click
      expect_no_content accept_modal_copy
      draft_title.click
      visible_tiles.count.should == 1
      suggestion_box_title.click
      visible_tiles.count.should == 3
    end
  end
end
