require 'acceptance/acceptance_helper'

feature 'Ensure carousel are in synch', js: true do

  let(:admin) { FactoryGirl.create(:client_admin) }
  let(:demo) { admin.demo }
  let(:tiles) { [] }

  before do
    UserIntro.any_instance.stubs(:displayed_first_tile_hint).returns(true)

    1.upto(4) do |i|
      tiles << FactoryGirl.create(:tile,  demo: demo, headline: "Tile #{i}", created_at: Time.current + i.days)
    end

    bypass_modal_overlays(admin)
  end

  scenario "displays recently created tiles in reversse creation order" do
    active_tile_headlines_order =  ["Tile 4", "Tile 3", "Tile 2", "Tile 1"]

    signin_as(admin, admin.password)
    visit tile_manager_page

    expect(section_tile_headlines('#active')).to eq(active_tile_headlines_order)

  end

  scenario "displays recently created tiles in reversse creation order" do
    active_tile_headlines_order =  ["Tile 4", "Tile 3", "Tile 2", "Tile 1"]
    signin_as(admin, admin.password)

    visit activity_path
    visit activity_path
    check_carousel_and_viewer(active_tile_headlines_order, Tile.first)
  end


  def carousel_content
    page.all('.headline .text').collect { |tile| tile.text }
  end

  def viewer_content
    find('#slideshow').find('.tile_image')[:alt]
  end


  def click_next_button
    page.find('#next').click
  end

  def check_carousel_and_viewer(active_tile_headlines_order, carousel_tile)
    expect(carousel_content).to eq(active_tile_headlines_order)
    click_carousel_tile(carousel_tile)
    click_next_button

    active_tile_headlines_order.each do |user_tile|
      next if user_tile == carousel_tile.headline
      expect(viewer_content).to eq(user_tile)
      click_next_button
    end
  end
end
