require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Admin Bulk Loads Users" do
  before do
    @demo = Factory :demo, :name => "H Engage", :credit_game_referrer_threshold => 60, :game_referrer_bonus => 2000
    signin_as_admin

    visit new_admin_demo_bulk_load_path(@demo)
  end

  scenario "with claim codes and usernames" do
    bulk_user_csv = <<-END_CSV
John Smith,jsmith@example.com,123123,johnny
Bob Jones,bjones@example.com,234234,bobby
Fred Robinson,frobinson@example.com,345345,freddy
    END_CSV

    fill_in "bulk_user_data", :with => bulk_user_csv
    click_button "Upload Users"
    expect_content "Successfully loaded 3 users"

    visit admin_demo_path(@demo)
    click_link "J"
    expect_content "John Smith, jsmith@example.com (123123)"

    click_link "B"
    expect_content "Bob Jones, bjones@example.com (234234)"

    click_link "F"
    expect_content "Fred Robinson, frobinson@example.com (345345)"

    mo_sms "+14155551212", "123123"
    mo_sms "+16175551212", "234234"

    expect_mt_sms "+14155551212", "You've joined the H Engage game! Your username is johnny (text MYID if you forget). To play, text to this #."
    expect_mt_sms "+16175551212", "You've joined the H Engage game! Your username is bobby (text MYID if you forget). To play, text to this #."

    mo_sms "+16175551212", "johnny"
    Delayed::Worker.new.work_off(10)
    expect_mt_sms "+16175551212", "Got it, John Smith referred you to the game. Thanks for letting us know."
    expect_mt_sms "+14155551212", "Bob Jones gave you credit for referring them to the game. Many thanks and 2000 bonus points!"
  end

  scenario "should have a link from the demo page" do
    visit admin_demo_path(@demo)
    click_link "Bulk load users"
    should_be_on new_admin_demo_bulk_load_path(@demo)
  end
end
