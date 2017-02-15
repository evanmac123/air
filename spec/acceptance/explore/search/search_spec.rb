require 'acceptance/acceptance_helper'

feature "Client admin searches", js: true, type: :feature do

  let!(:demo) { FactoryGirl.create :demo }
  let!(:client_admin) { FactoryGirl.create :site_admin, demo: demo }

  before do
    FactoryGirl.create_list(:tile, 5, :draft, demo: demo)
    FactoryGirl.create_list(:tile, 5, :active, demo: demo)
    FactoryGirl.create_list(:tile, 5, :archived, demo: demo)
    FactoryGirl.create_list(:tile, 5, :public)
    FactoryGirl.create_list(:campaign, 5)
  end

  it "should load 4 resources from each section on the overview page" do
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

  it "should load all tiles on resource specific tabs" do
    visit explore_search_path(as: client_admin, query: '*')

    find("#myTilesTab").click

    my_tiles_section = page.find(".manage_section.client_admin_tiles")

    within my_tiles_section do
      expect(page).to have_selector('.tile_container', count: 15)
    end

    find("#exploreTilesTab").click

    explore_section = page.find(".manage_section.explore_tiles")

    within explore_section do
      expect(page).to have_selector('.tile_container', count: 5)
    end

    find("#campaignsTab").click

    campaign_section = page.find(".campaigns.row")

    within campaign_section do
      expect(page).to have_selector('.tile_container', count: 5)
    end
  end
end
