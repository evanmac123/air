require 'acceptance/acceptance_helper'

# After this initial creation, note that 'admin' is used instead of 'client-admin'
feature 'Client admin and the digest email for tiles', js: true do

  let(:admin) { FactoryGirl.create :client_admin }
  let(:demo)  { admin.demo  }

  # -------------------------------------------------

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  # -------------------------------------------------

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

  def have_send_on_selector(options = {})
    have_select 'digest_send_on', options
  end

  def change_send_on(day)
    select day, from: 'digest_send_on'
  end
  # -------------------------------------------------

  scenario 'Tile-manager tabs work' do
    visit manage_tiles_page

    select_tab 'Archive'
    tab('Archive').should contain 'Archive tab section'

    select_tab 'Live'
    tab('Live').should contain 'Live tab section'
  end

  context 'No tiles exist for digest email' do

    before(:each) { visit manage_tiles_page }

    scenario 'Tab text is correct when there are no new tiles for the digest email' do
      last_email_sent_text = 'since the last one was sent on Thursday, July 04, 2013'

      tab('Live').should contain 'No digest email is scheduled to be sent because no new tiles have been added'
      tab('Live').should_not contain last_email_sent_text

      demo.update_attributes tile_digest_email_sent_at: Time.new(2013, 7, 4)
      refresh_tile_manager_page

      tab('Live').should contain last_email_sent_text
    end

    scenario 'Form components and text are not on the page when there are no new tiles for the digest email' do
      tab('Live').should_not have_send_on_selector
      tab('Live').should_not have_button 'Send now'
      tab('Live').should_not have_link   'View email'

      tab('Live').should_not contain 'A digest email containing'

      demo.update_attributes tile_digest_email_sent_at: Time.new(2013, 7, 4)
      refresh_tile_manager_page

      tab('Live').should_not contain 'Last digest email was sent on'
    end
  end

  context 'Tiles exist for digest email' do
    scenario "The number of tiles is correct, as is the plurality of the word 'tile'" do
      FactoryGirl.create :tile, demo: demo
      visit manage_tiles_page
      tab('Live').should contain 'A digest email containing 1 tile is set to go out'

      FactoryGirl.create :tile, demo: demo
      refresh_tile_manager_page
      tab('Live').should contain 'A digest email containing 2 tiles is set to go out'
    end

    scenario 'The appropriate form components are on the page and properly initialized' do
      FactoryGirl.create :tile, demo: demo
      visit manage_tiles_page

      tab('Live').should have_send_on_selector(selected: 'Never')
      tab('Live').should have_button 'Send now'
      tab('Live').should have_link   'View email'

      demo.update_attributes tile_digest_email_send_on: 'Tuesday'
      refresh_tile_manager_page
      tab('Live').should have_send_on_selector(selected: 'Tuesday')
    end

    scenario "The 'send_on' dropdown control updates the day and displays a flash message"  do
      FactoryGirl.create :tile, demo: demo
      visit manage_tiles_page

      tab('Live').should have_send_on_selector(selected: 'Never')

      change_send_on('Tuesday')
      refresh_tile_manager_page
      tab('Live').should have_send_on_selector(selected: 'Tuesday')

      change_send_on('Friday')
      refresh_tile_manager_page
      tab('Live').should have_send_on_selector(selected: 'Friday')
    end

    scenario 'The last-email-digest-email-sent-on date is correct' do
      demo.update_attributes tile_digest_email_sent_at: Time.new(2013, 7, 4)
      FactoryGirl.create :tile, demo: demo, created_at: Time.new(2013, 7, 5)

      visit manage_tiles_page
      tab('Live').should contain 'Last digest email was sent on Thursday, July 04, 2013'
    end
  end
end