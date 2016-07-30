require 'acceptance/acceptance_helper'

feature 'Client uses suggestion box' do
  include SuggestionBox

  let!(:demo) { FactoryGirl.create :demo }
  let!(:client_admin) { FactoryGirl.create :site_admin, demo: demo }

  context "Submitted Tile", js: true do

    let!(:tile) { FactoryGirl.create :multiple_choice_tile, :user_submitted, demo: demo }

    before do
      visit client_admin_tiles_path(as: client_admin)
      page.find("#suggestion_box_title").click
    end

    scenario "tile preview works properly" do
      page.find("#single-tile-#{tile.id}.user_submitted").click

      within "#suggested_info" do
        page.find(".header_text").text.should have_content("Submitted")
      end

      items = menu_items.map(&:text)
      items.should include("Accept")
      items.should include("Ignore")

      #FIXME write separate assertion in controller spec for server side ping if
      #necessary
      #expect_ping 'Suggestion Box', {client_admin_action: "Tile Viewed"}, client_admin
    end

    scenario "accepts tile" do
      click_link "Accept"
      within ".sweet-alert.visible" do
        click_button "OK"
      end
      #this waits for the ajax to finish and the alert window to close
      page.should_not have_css(".sweet-alert.visible")
      page.find("#draft_title").click
      within "#draft" do
        page.should have_css("#single-tile-#{tile.id}")
      end
    end

    context "Ignored Tile" do

      before  do

        within "#suggestion_box #single-tile-#{tile.id}" do
          click_link "Ignore"
        end 
      end

      scenario "should ignore tile" do
        within "#suggestion_box #single-tile-#{tile.id}" do
          page.should have_content("Undo Ignore")
        end
      end

      scenario "should undo ignore" do
        within "#suggestion_box #single-tile-#{tile.id}" do
          click_link("Undo Ignore")
        end

        within "#suggestion_box #single-tile-#{tile.id}" do
          page.should_not have_content("Undo Ignore")
        end
      end
    end
  end


  def menu_header
    page.find(".preview_menu_header")
  end

  def menu_items
    page.all(".preview_menu_item .header_text")
  end

  def intro_tooltip
    page.find(".tile_preview_intro")
  end


end
