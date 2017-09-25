require 'acceptance/acceptance_helper'

feature "User Confirms Phone number" do

  before(:each) do
    @phone_number = "+12224443321"
    @leah = FactoryGirl.create(:user, new_phone_number: @phone_number)
    @leah.generate_new_phone_validation_token
    @leah.save

    visit edit_account_settings_path(as: @leah)
  end

  it "should confirm her phone number if she enters her code" do
    fill_in 'user_new_phone_validation', with: @leah.new_phone_validation

    click_button 'Verify new number'

    expect(@leah.reload.phone_number).to eq(@phone_number)
    expect(page).to have_content("You have updated your phone number.")
  end

  it "should flash an error message if the wrong code is input" do
    fill_in 'user_new_phone_validation', :with => '883848838828348384283842834823848348384'
    click_button 'Verify new number'
    expect(current_path).to eq(edit_account_settings_path)

    expect(page).to have_content("Sorry, the code you entered was invalid. Please try typing it again.")
  end
end
