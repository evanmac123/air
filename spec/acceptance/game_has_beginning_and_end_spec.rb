require 'acceptance/acceptance_helper'

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
      visit edit_account_settings_path

      yield user
    end
  end

  context 'user changes settings' do
    it 'should allow user to change DOB when game is not open' do
      as_both_users do
        expect_value "Date of Birth", nil

        fill_in "Date of Birth", :with => "Jan 1, 1984"
        click_username_dob_gender_submit_button
        expect_content "OK, your settings were updated."
        expect_value "Date of Birth", "January 01, 1984"
      end
    end


    it 'should allow user to change gender when game is not open' do
      as_both_users do
        expect_none_selected "user[gender]"
        choose "male"
        click_username_dob_gender_submit_button
        expect_content "OK, your settings were updated"
        expect_checked "Male"
      end
    end

    it 'should allow user to change privacy settings when game is not open' do
      as_both_users do
        expect_selected "connected"
        select 'Everybody', :from => 'user[privacy_level]'
        page.find(:css, '#save-privacy-level').click
        expect_selected 'everybody'
      end
    end
  # Didn't work * Cannot add an avatar * Cannot update phone number ** Cannot change notification preferences (text, email or both)

    it 'should allow user to change avatar when game is not open' do
      as_both_users do
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
        expect_checked "both"
        choose "SMS"
        page.find(:css, '#save-notification-settings').click
        expect_checked 'SMS'
      end
    end

  end
end
