require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

metal_testing_hack(SmsController)

feature "Admin Bulk Loads Users" do
  before do
    @demo = FactoryGirl.create :demo, :with_phone_number, :name => "H Engage", :credit_game_referrer_threshold => 60, :game_referrer_bonus => 2000
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

    mo_sms "+14155551212", "123123", @demo.phone_number
    mo_sms "+16175551212", "234234", @demo.phone_number

    crank_dj_clear
    expect_mt_sms "+14155551212", "You've joined the H Engage game! Your username is johnny (text MYID if you forget). To play, text to this #."
    expect_mt_sms "+16175551212", "You've joined the H Engage game! Your username is bobby (text MYID if you forget). To play, text to this #."

    mo_sms "+16175551212", "johnny"
    
    crank_dj_clear

    expect_mt_sms "+16175551212", "Got it, John Smith referred you to the game. Thanks for letting us know."
    expect_mt_sms "+14155551212", "Bob Jones gave you credit for referring them to the game. Many thanks and 2000 bonus points!"
  end

  scenario "should have a link from the demo page" do
    visit admin_demo_path(@demo)
    click_link "Bulk load users"
    should_be_on new_admin_demo_bulk_load_path(@demo)
  end

  context "when there are characteristics available" do
    before(:each) do
      FactoryGirl.create :characteristic, :name => "Generic Characteristic 1"
      FactoryGirl.create :characteristic, :name => "Generic Characteristic 2", :allowed_values => %w(green red blue)
      FactoryGirl.create :characteristic, :demo_specific, :name => "Demo Characteristic 1", :demo => @demo, :allowed_values => %w(foo bar baz)
      FactoryGirl.create :characteristic, :demo_specific, :name => "Demo Characteristic 2", :demo => @demo 
      FactoryGirl.create :characteristic, :demo_specific, :name => "Other Demo Characteristic"
      visit new_admin_demo_bulk_load_path(@demo)
    end

    it "should allow those to be set while bulk loading", :js => true do
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
      expect_selected 'foo', 'Demo Characteristic 1'
      expect_selected 'blue', 'Generic Characteristic 2'
      expect_no_option_selected 'Demo Characteristic 2'
      expect_no_option_selected 'Generic Characteristic 1'

      visit admin_demo_path(@demo)
      click_link "Everyone"
      click_link "(edit Arthur Foobar)"
      expect_selected 'foo', 'Demo Characteristic 1'
      expect_no_option_selected 'Generic Characteristic 2'
      expect_no_option_selected 'Demo Characteristic 2'
      expect_no_option_selected 'Generic Characteristic 1'
    end

    it "should interpret non-discrete characteristics correctly", :js => true do
      number_characteristic = FactoryGirl.create(:characteristic, :number, :name => 'a number')
      date_characteristic = FactoryGirl.create(:characteristic, :date, :name => 'a date')
      boolean_characteristic = FactoryGirl.create(:characteristic, :boolean, :name => 'a boolean')

      visit new_admin_demo_bulk_load_path(@demo)

      3.times { click_link "Add characteristic" }
      select "a number", :from => "extra_column[4]" 
      select "a date", :from => "extra_column[5]"
      select "a boolean", :from => "extra_column[6]"

      bulk_user_csv = <<-END_CSV
John Smith,jsmith@example.com,123123,johnny,27.30,"May 4, 2010",1
      END_CSV
      fill_in "bulk_user_data", :with => bulk_user_csv
      click_button "Upload Users"
      expect_content "Successfully loaded 1 user"

      visit admin_demo_path(@demo)
      click_link "Everyone"
      click_link "(edit John Smith)"
     
      expect_value 'a number', '27.3'
      expect_value 'a date', '2010-05-04'
      expect_checked 'a boolean'
    end
  end
end
