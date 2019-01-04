require 'acceptance/acceptance_helper'

feature "User sets their mobile number on settings page" do
  def old_number
    "+14155551212"
  end

  def new_number
    "+16178675309"
  end

  def fill_in_mobile_number_field(new_number)
    fill_in "Mobile number", with: new_number
  end

  def set_new_number(new_number="617-867-5309")
    fill_in_mobile_number_field new_number
    find(".js-update-phone-number").click
  end

  def validate_new_number(token)
    fill_in "user_new_phone_validation", with: token
    click_button "Verify new number"
  end

  def expect_validation_field_visible
    expect(page.find('#user_new_phone_validation', visible: true)).to be_present
  end

  def expect_validation_field_not_visible
    expect(page.all('#user_new_phone_validation', visible: true)).to be_empty
  end

  let(:user) { FactoryBot.create(:user, phone_number: "+14155551212", receives_sms: true) }

  describe "when demo has default number" do
    before do
      visit edit_account_settings_path(as: user)
    end

    it "displays the current number on the settings page" do
      expect(page.find("#user_phone_number").value).to eq("(***)-***-1212")
    end

    it "shows validation after the number's changed but before it's verified" do
      set_new_number

      expect_content "To verify the number (***)-***-5309, please enter the validation code we sent to that number:"
      expect_validation_field_visible
    end

    it "sends an SMS to the new number" do
      set_new_number

      expected_text = "Your code to verify this phone with Airbo is #{user.reload.new_phone_validation}."
      message = FakeTwilio::Client.messages.last

      expect(message.to).to eq(new_number)
      expect(message.body).to eq(expected_text)
    end

    it "changes number after validation" do
      set_new_number
      user.reload
      validate_new_number user.new_phone_validation

      expect(user.reload.phone_number).to eq(new_number)
    end

    it "lets the user cancel the change by re-entering their current number" do
      set_new_number("(415) 555-1212")
      expect_validation_field_not_visible
    end

    it "does nothing much if the user submits their current phone number" do
      set_new_number "415-555-1212"
      expect(user.reload.phone_number).to eq(old_number)
      expect_validation_field_not_visible
    end
  end

  describe "when demo has custom number" do
    before do
      demo = user.demo
      demo.update_attributes(phone_number: "+18089871234")
      visit edit_account_settings_path(as: user)
    end

    it "prevents user from setting board number as own" do
      set_new_number(user.demo.phone_number)
      expect(page).to have_content("Sorry, but that phone number has already been taken. Need help? Contact support@airbo.com")
    end

    it "should send the validation SMS from short code number" do
      set_new_number

      message = FakeTwilio::Client.messages.first
      expect(message.from).to eq(TWILIO_SHORT_CODE)
      expect(message.to).to eq(new_number)
      expect(message.body).to eq("Your code to verify this phone with Airbo is #{user.reload.new_phone_validation}.")
    end
  end
end
