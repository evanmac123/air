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
        pending "FIX THIS SO IT DOESN'T NEED TO ACTUALLY ACCESS S3 SINCE THAT IS A VERY BAD THING"
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
        fill_in "Mobile number", :with => phone_number
        click_button 'save-notification-settings'
        expect_content "We have sent a verification code to #{phone_number}."
        crank_dj_clear
        expect_mt_sms_including formatted_phone, 'Your code to verify this phone'
        user.reload.new_phone_validation.should_not be_nil
        fill_in 'user_new_phone_validation', :with => user.new_phone_validation
        click_button 'Verify new number'
        expect_value 'Mobile number', phone_number
      end
    end

    it 'should allow user to change notification preferences when game is not open' do
      as_both_users do
        visit edit_account_settings_path
        expect_checked "email"
        choose "Text message"
        page.find(:css, '#save-notification-settings').click
        expect_checked 'Text message'
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

    scenario "should send back a reasonable error message", js: true do
      mo_sms(@past_user.phone_number, 'did thing')
      mo_sms(@future_user.phone_number, 'did thing')
      crank_dj_clear
      expect_mt_sms(@past_user.phone_number, "Thanks for participating. Your administrator has disabled this board. If you'd like more information e-mailed to you, please text INFO.")
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
end
