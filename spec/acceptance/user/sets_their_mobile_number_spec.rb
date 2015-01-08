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

  def expect_mobile_number_in_form(number)
    page.find("#user_phone_number").value.should == number.as_pretty_phone
  end

  def expect_validation_field_visible
    page.find('#user_new_phone_validation', visible: true).should be_present
  end

  def expect_validation_field_not_visible
    page.all('#user_new_phone_validation', visible: true).should be_empty
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
    expect_mobile_number_in_form old_number
  end

  it "shows validation after the number's changed but before it's verified" do
    set_new_number

    expect_content "We have sent a verification"
    expect_content "To verify the number (617) 867-5309, please enter the validation code we sent to that number:"
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

    user.reload.phone_number.should == new_number
  end

  it "lets the user cancel the change by re-entering their current number" do
    set_new_number("(415) 555-1212")
    expect_validation_field_not_visible
  end

  it "lets the user blank out their number without going through validation" do
    set_new_number('   ')

    user.reload.phone_number.should be_blank
    expect_content "OK, you won't get any more text messages from us."
    expect_validation_field_not_visible
    expect_no_content "() -"
    expect_no_content "Phone number can't be blank"
  end

  it "does nothing much if the user submits their current phone number" do
    set_new_number "415-555-1212"
    user.reload.phone_number.should == old_number
    expect_validation_field_not_visible
  end

  context "when the user is in a board with a custom phone number" do
    before do
      demo = user.demo
      demo.phone_number = "+18089871234"
      demo.save!
    end

    it "should send the validation SMS from that number" do
      set_new_number
      crank_dj_clear
      FakeTwilio::SMS.should have_sent_text_from("+18089871234", new_number)
    end
  end
end
