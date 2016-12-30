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
    click_button "save-notification-settings"
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

  def expect_validation_sms(number, token)
    expected_text = "Your code to verify this phone with Airbo is #{token}."
    expect_mt_sms(number, expected_text)
  end

  let(:user) { FactoryGirl.create(:user, phone_number: "+14155551212") }

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
    crank_dj_clear
    expect_validation_sms(new_number, user.reload.new_phone_validation)
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

  it "lets the user blank out their number without going through validation" do
    skip "The UX for setting phone numbers for needs to be cleaned up and this test improved" 
    set_new_number('   ')

    expect(user.reload.phone_number).to be_blank
    expect_content "You will no longer receive text messages from us."
    expect_validation_field_not_visible
    expect_no_content "() -"
    expect_no_content "Phone number can't be blank"
  end

  it "does nothing much if the user submits their current phone number" do
    set_new_number "415-555-1212"
    expect(user.reload.phone_number).to eq(old_number)
    expect_validation_field_not_visible
  end




  context "when the user is in a board with a custom phone number" do
    before do
      demo = user.demo
      demo.phone_number = "+18089871234"
      demo.save!
    end

    it "prevents user from setting board number as own" do
      set_new_number(user.demo.phone_number)
      expect(page).to have_content("Sorry, but that phone number has already been taken. Need help? Contact support@airbo.com")
    end

    it "should send the validation SMS from that number" do
      set_new_number
      crank_dj_clear
      expect(FakeTwilio::SMS).to have_sent_text_from("+18089871234", new_number)
    end
  end
end
