require 'acceptance/acceptance_helper'

feature 'Ensure carousel are in synch', js: true do

  let(:admin) { FactoryBot.create(:client_admin) }
  let(:demo) { admin.demo }
  let(:tiles) { [] }

  before do
    UserIntro.any_instance.stubs(:displayed_first_tile_hint).returns(true)

    1.upto(4) do |i|
      tiles << FactoryBot.create(:tile,  demo: demo, headline: "Tile #{i}", created_at: Time.current + i.days)
    end

    bypass_modal_overlays(admin)
  end

  scenario "displays recently created tiles in reversse creation order" do
    active_tile_headlines_order =  ["Tile 4", "Tile 3", "Tile 2", "Tile 1"]

    visit client_admin_tiles_path(as: admin)

    active_tab.click

    expect(visible_tile_headlines).to eq(active_tile_headlines_order)
  end
end
