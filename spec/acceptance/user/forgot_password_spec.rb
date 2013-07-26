require 'acceptance/acceptance_helper'

feature "User interacts with the 'Forgot password?' functionality" do

  before(:each) do
    visit sign_in_path
    click_link 'Forgot password?'
  end

  scenario 'User enters an invalid email address' do
    fill_in 'password_email', with: 'buddy@guy.com'
    click_button 'Reset password'
    page.should have_text 'Unknown email'
  end

  scenario 'Claimed user enters a valid email address' do
    FactoryGirl.create :claimed_user, email: 'buddy@guy.com'

    fill_in 'password_email', with: 'buddy@guy.com'
    click_button 'Reset password'
    page.should have_text 'You will receive an email within the next few minutes with a link to reset your password'
  end

  scenario 'Unclaimed user enters a valid email address' do
    FactoryGirl.create :user, email: 'buddy@guy.com'

    fill_in 'password_email', with: 'buddy@guy.com'
    click_button 'Reset password'
    page.should have_text "We're sorry, you need to join H.Engage before you can reset your password."
  end

end