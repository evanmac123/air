require 'acceptance/acceptance_helper'

feature "User Confirms Phone number" do

  before(:each) do
    @phone_number = "+12224443321"
    password = 'password'
    @leah = FactoryGirl.create(:user, new_phone_number: @phone_number, password: password)
    @leah.generate_short_numerical_validation_token
    signin_as(@leah, password)
    visit phone_verification_path
  end

  it "should confirm her phone number if she enters her code" do
    @leah.new_phone_validation.should_not be_blank
    fill_in 'user_new_phone_validation', :with => @leah.new_phone_validation

    click_button 'Enter'

    expect(current_path).to eq(activity_path)
    expect(@leah.reload.phone_number).to eq(@phone_number)
    expect(page).to have_content("Your phone number has been validated")
    expect_no_mt_sms(@phone_number)
    end

  it "should flash an error message if the wrong code is input" do
    fill_in 'user_new_phone_validation', :with => '883848838828348384283842834823848348384'
    click_button 'Enter'
    expect(current_path).to eq(phone_verification_path)

    page.should have_content("Sorry, the code you entered was invalid")
  end

  it "should resend the code if she clicks Resend", js: true do
    click_link "Resend"

    expect(current_path).to eq(phone_verification_path)
    expect(page).to have_content("We have resent your phone validation code to#{@leah.phone_number.as_pretty_phone}")
    expect(@leah.reload.new_phone_number).to eq(@phone_number)
    expect(@leah.phone_number).to be_blank
    expected_text = "Your code to verify this phone with Airbo is #{@leah.new_phone_validation}."
    expect_mt_sms(@phone_number, expected_text)
  end

  it "should cancel the new_phone_number field when she clicks Cancel", js: true do
    click_link 'Skip this step'

    expect(current_path).to eq(activity_path)
    expect(@leah.reload.new_phone_number).to be_blank
    expect(@leah.phone_number).to be_blank
  end
end
