require 'acceptance/acceptance_helper'

feature 'Archiv Tilesh', js: true do

  let(:admin) { FactoryGirl.create(:client_admin) }
  let(:demo) { admin.demo }
  let(:tiles) { [] }

  before do
    UserIntro.any_instance.stubs(:displayed_first_tile_hint).returns(true)

    1.upto(4) do |i|
      tiles << FactoryGirl.create(:tile,  demo: demo, headline: "Tile #{i}", created_at: Time.now + i.days)
    end

    bypass_modal_overlays(admin)
  end

  context 'Tile Manager' do

    scenario "Moves archived tile moves from active to archived section" do
      signin_as(admin, admin.password)
      visit tile_manager_page
      selector= "#single-tile-#{tiles[2].id}.tile_thumbnail>.tile-wrapper"
      within "#active_tiles" do
        page.find(selector).hover
        within selector do
          within(".tile_buttons") do
            click_link "Archive"
          end
        end
      end

      within "#archived_tiles" do
        expect(page).to have_content(tiles[2].headline)
      end

      within "#active_tiles" do
        expect(page).to have_no_content(tiles[2].headline)
      end
    end
  end
end
