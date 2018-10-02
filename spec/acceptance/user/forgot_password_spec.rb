require 'acceptance/acceptance_helper'

feature "User interacts with the 'Forgot password?' functionality", js: true do

  before(:each) do
    visit root_path(sign_in: true)
    wait_for_page_load
    find('#set_or_reset_password').click
  end

  scenario 'User enters an invalid email address' do
    fill_in 'password_email', with: 'buddy@guy.com'
    click_button 'Reset Password'
    expect(page).to have_text "We're sorry, we can't find your email address in our records. Please contact support@airbo.com for assistance."
  end

  scenario 'Claimed user enters a valid email address' do
    FactoryBot.create :claimed_user, email: 'buddy@guy.com'

    fill_in 'password_email', with: 'buddy@guy.com'
    click_button 'Reset Password'
    expect(page).to have_text 'Processing your reset password request'
  end

  scenario 'Unclaimed user enters a valid email address' do
    FactoryBot.create :user, email: 'buddy@guy.com'

    fill_in 'password_email', with: 'buddy@guy.com'
    click_button 'Reset Password'
    expect(page).to have_text "We're sorry, you need to join Airbo before you can reset your password."
  end

end
