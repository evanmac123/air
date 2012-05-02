require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Admin Bulk Loads Users" do
  before do
    puts "in before"
    @demo = FactoryGirl.create :demo, :name => "H Engage", :credit_game_referrer_threshold => 60, :game_referrer_bonus => 2000
    signin_as_admin

    visit new_admin_demo_bulk_load_path(@demo)
  end

  scenario "with claim codes and usernames" do
    puts "with claim codes"
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
    puts "should have a "
    visit admin_demo_path(@demo)
    click_link "Bulk load users"
    should_be_on new_admin_demo_bulk_load_path(@demo)
  end

  context "when there are characteristics available" do
    before(:each) do
      puts "second before each"
      FactoryGirl.create :characteristic, :name => "Generic Characteristic 1"
      FactoryGirl.create :characteristic, :name => "Generic Characteristic 2", :allowed_values => %w(green red blue)
      FactoryGirl.create :demo_specific_characteristic, :name => "Demo Characteristic 1", :demo => @demo, :allowed_values => %w(foo bar baz)
      FactoryGirl.create :demo_specific_characteristic, :name => "Demo Characteristic 2", :demo => @demo 
      FactoryGirl.create :demo_specific_characteristic, :name => "Other Demo Characteristic"
      visit new_admin_demo_bulk_load_path(@demo)
    end

    it "should allow those to be set while bulk loading", :js => true do
      puts "should allow"
      3.times { click_link "Add characteristic" }
      select "Demo Characteristic 1", :from => "extra_column[4]" 
      select "Generic Characteristic 2", :from => "extra_column[6]"

      bulk_user_csv = <<-END_CSV
John Smith,jsmith@example.com,123123,johnny,foo,nonsense,blue
Bob Jones,bjones@example.com,234234,bobby,badvalue,irrelevant,green
Fred Robinson,frobinson@example.com,345345,freddy,bar,this doesn't matter,badvalue
Arthur Foobar,afoobar@example.com,456456,art,foo,,
      END_CSV

      fill_in "bulk_user_data", :with => bulk_user_csv
      click_button "Upload Users"
      expect_content "Successfully loaded 2 users"

      visit admin_demo_path(@demo)
      click_link "Everyone"
      expect_no_content "Bob Jones"
      expect_no_content "Fred Robinson"
      expect_content "John Smith, jsmith@example.com (123123)"
      expect_content "Arthur Foobar, afoobar@example.com (456456)"

      click_link "(edit John Smith)"
      expect_selected 'Demo Characteristic 1', 'foo'
      expect_selected 'Generic Characteristic 2', 'blue'
      expect_no_option_selected 'Demo Characteristic 2'
      expect_no_option_selected 'Generic Characteristic 1'

      visit admin_demo_path(@demo)
      click_link "Everyone"
      click_link "(edit Arthur Foobar)"
      expect_selected 'Demo Characteristic 1', 'foo'
      expect_no_option_selected 'Generic Characteristic 2'
      expect_no_option_selected 'Demo Characteristic 2'
      expect_no_option_selected 'Generic Characteristic 1'
    end
  end
end
