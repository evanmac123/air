require 'acceptance/acceptance_helper'

feature "Client admin searches", js: true do

  let!(:demo) { FactoryGirl.create :demo }
  let!(:client_admin) { FactoryGirl.create :site_admin, demo: demo }

  before do
    FactoryGirl.create_list(:tile, 5, :draft, demo: demo)
    FactoryGirl.create_list(:tile, 5, :active, demo: demo)
    FactoryGirl.create_list(:tile, 5, :archived, demo: demo)
    FactoryGirl.create_list(:tile, 5, :public)
    FactoryGirl.create_list(:campaign, 5)
  end

  it "should load 4 resources from each section on the overview page", search: true do
    visit explore_search_path(as: client_admin, query: '*')

    my_tiles_section = page.find(".manage_section.client_admin_tiles")

    within my_tiles_section do
      expect(page).to have_selector('.tile_container', count: 4)
    end

    explore_section = page.find(".manage_section.explore_tiles")

    within explore_section do
      expect(page).to have_selector('.tile_container', count: 4)
    end

    campaign_section = page.find(".manage_section.campaigns")

    within campaign_section do
      expect(page).to have_selector('.tile_container', count: 4)
    end
  end
end
