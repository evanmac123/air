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
    current_path.should == activity_path
    @leah.reload.phone_number.should == @phone_number
    page.should have_content("Your phone number has been validated")
    expect_no_mt_sms(@phone_number)
    end

  it "should flash an error message if the wrong code is input" do
    fill_in 'user_new_phone_validation', :with => '883848838828348384283842834823848348384'
    click_button 'Enter'
    current_path.should == phone_verification_path
    page.should have_content("Sorry, the code you entered was invalid")
  end

  it "should resend the code if she clicks Resend", js: true do
    Delayed::Job.delete_all
    click_link "Resend"
    current_path.should == phone_verification_path
    page.should have_content("We have resent your phone validation code to#{@leah.phone_number.as_pretty_phone}")
    @leah.reload.new_phone_number.should == @phone_number
    @leah.phone_number.should be_blank
    crank_dj_clear
    expected_text = "Your code to verify this phone with Airbo is #{@leah.new_phone_validation}."
    expect_mt_sms(@phone_number, expected_text)
  end

  it "should cancel the new_phone_number field when she clicks Cancel", js: true do 
    click_link 'Skip this step'
    current_path.should == activity_path
    @leah.reload.new_phone_number.should be_blank
    @leah.phone_number.should be_blank
  end

end
