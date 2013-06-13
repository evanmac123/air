require 'acceptance/acceptance_helper'

feature 'Client admin and the digest email for tiles' do

  let(:admin) { FactoryGirl.create :client_admin }
  let(:demo)  { admin.demo  }

  # -------------------------------------------------

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  # -------------------------------------------------

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
    demo.update_attributes tile_digest_email_sent_at: day_to_time(day)
  end

# -------------------------------------------------

  context 'No tiles exist for digest email' do

    before(:each) do
      visit tile_manager_page
      select_tab 'Digest'
    end

    scenario 'Tab text is correct when there are no new tiles for the digest email' do
      last_email_sent_text = 'since the last one was sent on Thursday, July 04, 2013'

      digest_tab.should contain 'No digest email is scheduled to be sent because no new tiles have been added'
      digest_tab.should_not contain last_email_sent_text

      set_last_sent_on '7/4/2013'
      refresh_tile_manager_page

      digest_tab.should contain last_email_sent_text
    end

    scenario 'Form components and text are not on the page when there are no new tiles for the digest email' do
      digest_tab.should_not have_send_on_selector
      digest_tab.should_not have_button 'Send now'

      digest_tab.should_not contain 'A digest email containing'

      set_last_sent_on '7/4/2013'
      refresh_tile_manager_page

      digest_tab.should_not contain 'Last digest email was sent on'
    end
  end

  context 'Tiles exist for digest email' do
    scenario "The number of tiles is correct, as is the plurality of the word 'tile'" do
      create_tile
      visit tile_manager_page
      select_tab 'Digest'

      digest_tab.should contain 'A digest email containing 1 tile is set to go out'

      create_tile
      refresh_tile_manager_page
      select_tab 'Digest'

      digest_tab.should contain 'A digest email containing 2 tiles is set to go out'
    end

    scenario 'The appropriate form components are on the page and properly initialized', js: true do
      create_tile
      visit tile_manager_page
      select_tab 'Digest'

      digest_tab.should have_send_on_selector('Never')
      digest_tab.should have_button 'Send now'

      set_send_on 'Tuesday'
      refresh_tile_manager_page
      select_tab 'Digest'

      digest_tab.should have_send_on_selector('Tuesday')
    end

    scenario "The 'send_on' dropdown control updates the day and time, and displays a confirmation message", js: true do
      create_tile
      visit tile_manager_page

      select_tab 'Digest'
      digest_tab.should have_send_on_selector('Never')
      digest_tab.should_not contain 'at noon,'

      change_send_on 'Tuesday'
      page.should contain 'Digest email weekly-send-on day was updated to Tuesday'

      select_tab 'Digest'
      digest_tab.should have_send_on_selector('Tuesday')
      digest_tab.should contain 'at noon,'

      change_send_on 'Friday'
      page.should contain 'Digest email weekly-send-on day was updated to Friday'

      select_tab 'Digest'
      digest_tab.should have_send_on_selector('Friday')
      digest_tab.should contain 'at noon,'

      change_send_on 'Never'
      page.should contain 'Digest email weekly-send-on day was updated to Never'

      select_tab 'Digest'
      digest_tab.should_not contain 'at noon,'
    end

    scenario 'The last-digest-email-sent-on date is correct' do
      set_last_sent_on '7/4/2013'
      create_tile on_day: '7/5/2013'

      visit tile_manager_page
      select_tab 'Digest'

      digest_tab.should contain 'Last digest email was sent on Thursday, July 04, 2013'
    end

    scenario "The 'Send now' button causes all digest tiles to become invisible and a no-digest-tiles message to be displayed", js: true do
      set_last_sent_on '7/4/2013'
      2.times { |i| create_tile on_day: '7/5/2013', headline: "Headline #{i + 1}"}

      on_day '7/6/2013' do
        visit tile_manager_page
        select_tab 'Digest'

        digest_tab.should     contain 'A digest email containing 2 tiles is set to go out'
        digest_tab.should_not contain 'No digest email is scheduled to be sent'
        digest_tab.should_not contain 'since the last one was sent on Saturday, July 06, 2013'

        digest_tab.should contain 'Headline 1'
        digest_tab.should contain 'Headline 2'
        digest_tab.should contain 'Forever'

        digest_tab.should have_num_tiles(2, visible: true)

        click_button 'Send now'

        digest_tab.should_not contain 'A digest email containing 2 tiles is set to go out'
        digest_tab.should     contain 'No digest email is scheduled to be sent'
        digest_tab.should     contain 'since the last one was sent on Saturday, July 06, 2013'

        digest_tab.should_not contain 'Headline 1'
        digest_tab.should_not contain 'Headline 2'
        digest_tab.should_not contain 'Forever'

        digest_tab.should have_num_tiles(2, visible: false)
      end
    end
  end
end