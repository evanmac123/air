require "spec_helper"

include TileHelpers

  scenario 'emails are sent to the appropriate people' do
    FactoryGirl.create :user, demo: demo, name: 'John Campbell', email: 'john@campbell.com'
    FactoryGirl.create :user, demo: demo, name: 'Irma Thoman',   email: 'irma@thomas.com'

    FactoryGirl.create :claimed_user, demo: demo, name: 'W.C. Clark', email: 'wc@clark.com'
    FactoryGirl.create :claimed_user, demo: demo, name: 'Taj Mahal',  email: 'taj@mahal.com'

    FactoryGirl.create :user, demo: FactoryGirl.create(:demo)  # Make sure this user doesn't get an email

    on_day '7/6/2013' do
      visit tile_manager_page
      select_tab 'Digest'

      click_button 'Send now'
      crank_dj_clear

      all_emails.should have(5).emails  # The above 4 for this demo, and the 'admin' created at top of tests

      %w(admin@hengage.com john@campbell.com irma@thomas.com wc@clark.com taj@mahal.com).each do |address|
        find_email(address).should_not be_nil
      end
    end
  end

##############################

#todo done => need to create more than one demo on days that emails get sent to verify that all appropriate demos send emails.
describe 'Daily digest emails sent automatically by delayed_job' do
  it 'should do the right thing' do
    # Demos ----------------------
    monday_demo_with_tiles    = FactoryGirl.create :demo, tile_digest_email_send_on: 'Monday', tile_digest_email_sent_at: 1.day.ago
    monday_demo_with_no_tiles = FactoryGirl.create :demo, tile_digest_email_send_on: 'Monday', tile_digest_email_sent_at: 1.day.ago

    friday_demo_with_tiles    = FactoryGirl.create :demo, tile_digest_email_send_on: 'Friday', tile_digest_email_sent_at: 1.day.ago
    friday_demo_with_no_tiles = FactoryGirl.create :demo, tile_digest_email_send_on: 'Friday', tile_digest_email_sent_at: 1.day.ago

    # Tiles that should go out (created after the 'last-sent-date' and not 'archived')----------------------
    monday_tile_1 = FactoryGirl.create :tile, demo: monday_demo_with_tiles, headline: 'monday_tile_1'
    monday_tile_2 = FactoryGirl.create :tile, demo: monday_demo_with_tiles, headline: 'monday_tile_2'
    monday_tile_3 = FactoryGirl.create :tile, demo: monday_demo_with_tiles, headline: 'monday_tile_3'

    friday_tile_1 = FactoryGirl.create :tile, demo: friday_demo_with_tiles, headline: 'friday_tile_1'
    friday_tile_2 = FactoryGirl.create :tile, demo: friday_demo_with_tiles, headline: 'friday_tile_2'
    friday_tile_3 = FactoryGirl.create :tile, demo: friday_demo_with_tiles, headline: 'friday_tile_3'

    # Tiles that should not go out ----------------------
    # For Monday, create a few that are older than the 'last-sent-at' date ; For Friday, create some 'archived' tiles
    monday_no_tile_1 = FactoryGirl.create :tile, demo: monday_demo_with_no_tiles, headline: 'monday_no_tile_1', created_on: 2.days.ago
    monday_no_tile_2 = FactoryGirl.create :tile, demo: monday_demo_with_no_tiles, headline: 'monday_no_tile_2', created_on: 2.days.ago
    monday_no_tile_3 = FactoryGirl.create :tile, demo: monday_demo_with_no_tiles, headline: 'monday_no_tile_3', created_on: 2.days.ago

    friday_no_tile_1 = FactoryGirl.create :tile, demo: friday_demo_with_no_tiles, headline: 'friday_no_tile_1', status: Tile::ARCHIVE
    friday_no_tile_2 = FactoryGirl.create :tile, demo: friday_demo_with_no_tiles, headline: 'friday_no_tile_2', status: Tile::ARCHIVE
    friday_no_tile_3 = FactoryGirl.create :tile, demo: friday_demo_with_no_tiles, headline: 'friday_no_tile_3', status: Tile::ARCHIVE

    # Users (Some claimed and some not. Shouldn't make a difference... but make sure it doesn't)----------------------
    monday_user_1 = FactoryGirl.create :claimed_user, demo: monday_demo_with_tiles, email: 'user_1@monday.com'
    monday_user_2 = FactoryGirl.create :user,         demo: monday_demo_with_tiles, email: 'user_2@monday.com'
    monday_user_3 = FactoryGirl.create :claimed_user, demo: monday_demo_with_tiles, email: 'user_3@monday.com'

    friday_user_1 = FactoryGirl.create :user,         demo: friday_demo_with_tiles, email: 'user_1@friday.com'
    friday_user_2 = FactoryGirl.create :claimed_user, demo: friday_demo_with_tiles, email: 'user_2@friday.com'
    friday_user_3 = FactoryGirl.create :user,         demo: friday_demo_with_tiles, email: 'user_3@friday.com'


  end
end
