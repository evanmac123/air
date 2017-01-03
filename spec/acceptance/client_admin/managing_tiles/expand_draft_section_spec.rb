require 'acceptance/acceptance_helper'

feature 'Client expands draft section' do
  let(:admin) { FactoryGirl.create :client_admin }
  let(:demo)  { admin.demo  }

  def tile_selector
    ".tile_container:not(.placeholder_container)"
  end

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  before do
    FactoryGirl.create_list :multiple_choice_tile, 7, :draft, demo: demo
    visit client_admin_tiles_path
  end

  it "works as expected", js: true do
    expect(page.all(tile_selector, visible: true).count).to eq(6)
    page.find(".all_draft").click
    expect(page.all(tile_selector, visible: true).count).to eq(7)
  end
end
