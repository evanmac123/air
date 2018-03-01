require 'acceptance/acceptance_helper'

feature 'archive tiles', js: true do

  let(:admin) { FactoryBot.create(:client_admin) }
  let(:demo) { admin.demo }
  let(:tiles) { [] }

  before do
    1.upto(4) do |i|
      tiles << FactoryBot.create(:tile,  demo: demo, headline: "Tile #{i}", created_at: Time.current + i.days)
    end

    bypass_modal_overlays(admin)
  end

  context 'Tile Manager' do
    scenario "Moves archived tile moves from active to archived section" do
      visit client_admin_tiles_path(as: admin)

      selector= "#single-tile-#{tiles[2].id}.tile_thumbnail>.tile-wrapper"

      active_tab.click

      page.find(selector).hover
      within selector do
        within(".tile_buttons") do
          click_link "Archive"
        end
      end

      archive_tab.click
      expect(page).to have_content(tiles[2].headline)

    end
  end
end
