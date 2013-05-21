require 'acceptance/acceptance_helper'

feature 'Client admin navigatest to the Tile Manager page/tab' do

  let(:client_admin) { FactoryGirl.create :client_admin }
  let(:demo)         { client_admin.demo  }

  # -------------------------------------------------

  def select_tab(tab)
    click_link tab
  end

  def manage_tiles_page
    client_admin_tiles_path
  end

  # -------------------------------------------------

  background do
    bypass_modal_overlays(client_admin)
    signin_as(client_admin, client_admin.password)
    visit manage_tiles_page
  end

  # -------------------------------------------------

  scenario 'Tile-manager tabs work', js: true do
    select_tab 'Archive'
    page.should have_text 'Archive tab section'

    select_tab 'Live'
    page.should have_text 'Live tab section'
  end
end