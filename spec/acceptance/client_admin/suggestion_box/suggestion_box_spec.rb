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
        expect(page.find(".header_text").text).to have_content("Submitted")
      end

      items = menu_items.map(&:text)
      expect(items).to include("Accept")
      expect(items).to include("Ignore")
    end

    scenario "accepts tile" do
      within ".tile_container .user_submitted" do
        page.find(".tile-wrapper").hover
      end

      click_link "Accept"

      within ".sweet-alert.visible" do
        click_button "OK"
      end

      #this waits for the ajax to finish and the alert window to close
      expect(page).not_to have_css(".sweet-alert.visible")

      page.find("#draft_title").click

      within "#draft" do
        expect(page).to have_css("#single-tile-#{tile.id}")
      end
    end

    context "Ignored Tile" do

      before  do
        within ".tile_container .user_submitted" do
          page.find(".tile-wrapper").hover
        end
        within "#suggestion_box #single-tile-#{tile.id}" do
          click_link "Ignore"
        end
      end

      scenario "should ignore tile" do
        within "#suggestion_box #single-tile-#{tile.id}" do
          expect(page).to have_content("Undo Ignore")
        end
      end

      scenario "should undo ignore" do
        within "#suggestion_box #single-tile-#{tile.id}" do
          click_link("Undo Ignore")
        end

        within "#suggestion_box #single-tile-#{tile.id}" do
          expect(page).not_to have_content("Undo Ignore")
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
