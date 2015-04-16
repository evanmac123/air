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
    FactoryGirl.create_list :multiple_choice_tile, 5, :draft, demo: demo
    visit client_admin_tiles_path
  end

  it "works as expected", js: true do
    page.all(tile_selector, visible: true).count.should == 3
    page.find(".all_draft").click
    page.all(tile_selector, visible: true).count.should == 5
  end
end