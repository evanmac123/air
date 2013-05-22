require 'acceptance/acceptance_helper'

# After this initial creation, note that 'admin' is used instead of 'client-admin'
feature 'Client admin and the digest email for tiles', js: true do

  let(:admin) { FactoryGirl.create :client_admin }
  let(:demo)  { admin.demo  }

  # -------------------------------------------------

  background do
    admin_login
    visit manage_tiles_page
  end

  # -------------------------------------------------

  def admin_login
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  def select_tab(tab)
    click_link tab
  end

  def manage_tiles_page
    client_admin_tiles_path
  end

  def tab(label)
    find("#tile-manager-tabs ##{label.downcase}")
  end

  def contain(text)
    have_text text
  end

  def refresh_tile_manager_page
    visit manage_tiles_page
  end

  def have_day_selector
    have_selector '#digest_send_on'
  end

  # -------------------------------------------------

  scenario 'Tile-manager tabs work' do
    select_tab 'Archive'
    tab('Archive').should contain 'Archive tab section'

    select_tab 'Live'
    tab('Live').should contain 'Live tab section'
  end

  scenario 'Tab text is correct when there are no new tiles for the digest email' do
    last_email_sent_text = 'since the last one was sent on Thursday, July 04, 2013'

    tab('Live').should contain 'No digest email is scheduled to be sent because no new tiles have been added'
    tab('Live').should_not contain last_email_sent_text

    demo.update_attributes tile_digest_email_sent_at: Time.new(2013, 7, 4)
    refresh_tile_manager_page

    tab('Live').should contain last_email_sent_text
  end

  scenario 'Form components are not on the page when there are no new tiles for the digest email' do
    tab('Live').should_not have_day_selector
    tab('Live').should_not have_button 'Send now'
    tab('Live').should_not have_link   'View email'
  end
end