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

  DATE_REG_EXPR = /(\d{1,2})\/(\d{1,2})\/(\d{4})/  # e.g. 7/4/2013

  # So we can use the same kind of date-strings throughout the tests. (Need to redefine a class method.)
  class << Timecop
    alias old_travel travel

    def travel(day)
      day.match DATE_REG_EXPR
      time = Time.new $3, $1, $2
      old_travel(time)
    end
  end

  # -------------------------------------------------

  def live_tab
    tab('Live')
  end

  def archive_tab
    tab('Archive')
  end

  def tab(label)
    find("#tile-manager-tabs ##{label.downcase}")
  end

  def select_tab(tab)
    click_link tab
  end

  def manage_tiles_page
    client_admin_tiles_path
  end

  def contain(text)
    have_text text
  end

  def refresh_tile_manager_page
    visit manage_tiles_page
  end

  def have_send_on_selector(select = nil)
    options = select.nil? ? {} : {selected: select}
    have_select 'digest_send_on', options
  end

  def change_send_on(day)
    select day, from: 'digest_send_on'
  end

  def set_send_on(day)
    demo.update_attributes tile_digest_email_send_on: day
  end

  def set_last_sent_on(day)
    day.match DATE_REG_EXPR
    time = Time.new $3, $1, $2

    demo.update_attributes tile_digest_email_sent_at: time
  end

  def create_tile(options = {})
    date = options.delete :on
    if date
      date.match DATE_REG_EXPR
      options[:created_at] = Time.new $3, $1, $2
    end

    FactoryGirl.create :tile, options.merge(demo: demo)
  end

  # -------------------------------------------------

  scenario 'Tile-manager tabs work' do
    visit manage_tiles_page

    select_tab 'Archive'
    archive_tab.should contain 'Archive tab section'

    select_tab 'Live'
    live_tab.should contain 'Live tab section'
  end

  context 'No tiles exist for digest email' do

    before(:each) { visit manage_tiles_page }

    scenario 'Tab text is correct when there are no new tiles for the digest email' do
      last_email_sent_text = 'since the last one was sent on Thursday, July 04, 2013'

      live_tab.should contain 'No digest email is scheduled to be sent because no new tiles have been added'
      live_tab.should_not contain last_email_sent_text

      set_last_sent_on '7/4/2013'
      refresh_tile_manager_page

      live_tab.should contain last_email_sent_text
    end

    scenario 'Form components and text are not on the page when there are no new tiles for the digest email' do
      live_tab.should_not have_send_on_selector
      live_tab.should_not have_button 'Send now'
      live_tab.should_not have_link   'View email'

      live_tab.should_not contain 'A digest email containing'

      set_last_sent_on '7/4/2013'
      refresh_tile_manager_page

      live_tab.should_not contain 'Last digest email was sent on'
    end
  end

  context 'Tiles exist for digest email' do
    scenario "The number of tiles is correct, as is the plurality of the word 'tile'" do
      create_tile
      visit manage_tiles_page
      live_tab.should contain 'A digest email containing 1 tile is set to go out'

      create_tile
      refresh_tile_manager_page
      live_tab.should contain 'A digest email containing 2 tiles is set to go out'
    end

    scenario 'The appropriate form components are on the page and properly initialized' do
      create_tile
      visit manage_tiles_page

      live_tab.should have_send_on_selector('Never')
      live_tab.should have_button 'Send now'
      live_tab.should have_link   'View email'

      set_send_on 'Tuesday'
      refresh_tile_manager_page
      live_tab.should have_send_on_selector('Tuesday')
    end

    scenario "The 'send_on' dropdown control updates the day and time, and displays a confirmation message"  do
      create_tile
      visit manage_tiles_page

      live_tab.should have_send_on_selector('Never')
      live_tab.should_not contain 'at noon,'

      change_send_on 'Tuesday'
      live_tab.should have_send_on_selector('Tuesday')
      live_tab.should contain 'Send-on day updated to Tuesday'
      live_tab.should contain 'at noon,'

      change_send_on 'Friday'
      live_tab.should have_send_on_selector('Friday')
      live_tab.should contain 'Send-on day updated to Friday'
      live_tab.should contain 'at noon,'

      refresh_tile_manager_page
      live_tab.should contain 'at noon,'

      change_send_on 'Never'
      live_tab.should_not contain 'at noon,'
    end

    scenario 'The last-digest-email-sent-on date is correct' do
      set_last_sent_on '7/4/2013'
      create_tile on: '7/5/2013'

      visit manage_tiles_page
      live_tab.should contain 'Last digest email was sent on Thursday, July 04, 2013'
    end

    scenario "The 'Send now' button displays a confirmation message and updates the date in the 'Last email sent on' text"  do
      set_last_sent_on '7/4/2013'
      create_tile on: '7/5/2013'

      Timecop.travel '7/6/2013'

      visit manage_tiles_page
      live_tab.should contain 'Last digest email was sent on Thursday, July 04, 2013'

      click_button 'Send now'
      live_tab.should contain 'Digest email sent'
      live_tab.should contain 'Last digest email was sent on Saturday, July 06, 2013'

      visit manage_tiles_page
      live_tab.should contain 'No digest email is scheduled to be sent because no new tiles have been added'

      Timecop.return
    end
  end
end