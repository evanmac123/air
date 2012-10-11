require 'acceptance/acceptance_helper'
metal_testing_hack(SmsController)

feature 'Game has beginning and end' do
  before(:each) do
    @future_demo = FactoryGirl.create(:demo, begins_at: Time.now + 1.year, ends_at: Time.now + 2.years)
    @future_user = FactoryGirl.create(:user, :claimed, demo: @future_demo)

    @past_demo = FactoryGirl.create(:demo, begins_at: Time.now - 2.years, ends_at: Time.now - 1.year)
    @past_user = FactoryGirl.create(:user, :claimed, demo: @past_demo)

    has_password @future_user, 'foobar'
    has_password @past_user, 'foobar'
  end

  def click_username_dob_gender_submit_button
    click_submit_in_form("#username_dob_gender")
  end

  def as_both_users
    [@future_user, @past_user].each do |user|
      signin_as user, 'foobar'

      yield user
    end
  end

  def for_both_demos
    [@future_demo, @past_demo].each do |demo|
      yield demo
    end
  end

  context 'user changes settings' do
    it 'should allow user to change DOB when game is not open' do
      as_both_users do
        visit edit_account_settings_path
        expect_value "Date of Birth", nil

        fill_in "Date of Birth", :with => "Jan 1, 1984"
        click_username_dob_gender_submit_button
        expect_content "OK, your settings were updated."
        expect_value "Date of Birth", "January 01, 1984"
      end
    end


    it 'should allow user to change gender when game is not open' do
      as_both_users do
        visit edit_account_settings_path
        expect_none_selected "user[gender]"
        choose "male"
        click_username_dob_gender_submit_button
        expect_content "OK, your settings were updated"
        expect_checked "Male"
      end
    end

    it 'should allow user to change privacy settings when game is not open' do
      as_both_users do
        visit edit_account_settings_path
        expect_selected "connected"
        select 'Everybody', :from => 'user[privacy_level]'
        page.find(:css, '#save-privacy-level').click
        expect_selected 'everybody'
      end
    end

    it 'should allow user to change avatar when game is not open' do
      as_both_users do
        visit edit_account_settings_path
        attach_file "user[avatar]", Rails.root.join('features', 'support', 'fixtures', 'avatars', 'maggie.jpg')
        click_button "Upload"
        expect_avatar_in_masthead 'maggie.png'

        click_button "Clear"
        expect_default_avatar_in_masthead
      end
    end


    it 'should allow user to change phone number when game is not open' do
      as_both_users do |user|
        # make a different phone # for each of the two users
        last_digit_of_phone_number = user.id % 10
        phone_number = "(415) 261-307" + last_digit_of_phone_number.to_s
        formatted_phone = "+1415261307" + last_digit_of_phone_number.to_s

        visit edit_account_settings_path
        fill_in "Mobile Number", :with => phone_number
        click_button 'save-notification-settings'
        expect_content "We have sent a verification code to #{phone_number}."
        crank_dj_clear
        expect_mt_sms_including formatted_phone, 'Your code to verify this phone'
        user.reload.new_phone_validation.should_not be_nil
        fill_in 'user_new_phone_validation', :with => user.new_phone_validation
        click_button 'Verify New Number'
        expect_value 'Mobile Number', phone_number
      end
    end

    it 'should allow user to change notification preferences when game is not open' do
      as_both_users do
        visit edit_account_settings_path
        expect_checked "both"
        choose "SMS"
        page.find(:css, '#save-notification-settings').click
        expect_checked 'SMS'
      end
    end

  end

  context "sending messages to the game" do
    before(:each) do
      @past_user.update_attributes(phone_number: "+14155551212")
      @future_user.update_attributes(phone_number: "+16175551212")

      @rule = FactoryGirl.create(:rule, reply: "You did a thing")
      FactoryGirl.create(:rule_value, value: 'did thing', is_primary: true, rule: @rule)
    end

    scenario "should send back a reasonable error message" do
      mo_sms(@past_user.phone_number, 'did thing')
      mo_sms(@future_user.phone_number, 'did thing')
      crank_dj_clear

      expect_mt_sms(@past_user.phone_number, "Thanks for playing! The game is now over. If you'd like more information e-mailed to you, please text INFO.")
      expect_mt_sms(@future_user.phone_number, "The game will begin #{@future_demo.begins_at.pretty}. Please try again after that time.")
    end

    context "in a game with custom messages for this" do
      before(:each) do
        @past_demo.update_attributes(act_too_late_message: "Too late!")
        @future_demo.update_attributes(act_too_early_message: "Too early!")
      end

      it "should send those back" do
        mo_sms(@past_user.phone_number, 'did thing')
        mo_sms(@future_user.phone_number, 'did thing')
        crank_dj_clear

        expect_mt_sms(@past_user.phone_number, "Too late!")
        expect_mt_sms(@future_user.phone_number, "Too early!")
      end
    end
  end

  context "the invite modal on the activity page of a game that hasn't begun" do
    context "if the demo is not set to have it show when the game is closed (the default)" do
      it "should not appear", :js => true do
        signin_as @future_user, 'foobar'
        should_be_on activity_path(:format => :html)
        page.all('#facebox').should be_empty
      end
    end

    context "if the demo is set to have it show when the game is closed" do
      before(:each) do
        @future_demo.update_attributes(show_invite_modal_when_game_closed: true)
      end

      it "should appear as normal", :js => true do
        signin_as @future_user, 'foobar'
        should_be_on activity_path(:format => :html)
        page.find('#facebox').should have_content('Invite your friends')
      end
    end
  end
end
