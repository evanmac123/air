require 'acceptance/acceptance_helper'

feature 'User changes their own password' do
  before(:each) do
    @user = FactoryGirl.create(:user, :claimed)
    has_password @user, 'foobar'
    signin_as @user, 'foobar'
    visit edit_account_settings_path
  end

  
  scenario 'correctly' do
    fill_in "New password", :with => "barbaz"
    fill_in "Confirm new password", :with => "barbaz"
    click_save_password_button

    should_be_on edit_account_settings_path
    expect_content "Your password has been updated"
    expect_new_password_works('barbaz')
  end

  scenario 'leaving password blank' do
    fill_in "Confirm new password", :with => "barbaz"
    click_save_password_button

    should_be_on edit_account_settings_path
    expect_content "If you'd like to change your password, please fill in both the password and password confirmation with the same value."
    expect_new_password_doesnt_work('barbaz')
  end

  scenario 'leaving password confirmation blank' do
    fill_in "New password", :with => "barbaz"
    click_save_password_button

    should_be_on edit_account_settings_path
    expect_content "If you'd like to change your password, please fill in both the password and password confirmation with the same value."
    expect_new_password_doesnt_work('barbaz')
  end

  scenario 'leaving both password and confirmation blank' do
    click_save_password_button

    should_be_on edit_account_settings_path
    expect_content "If you'd like to change your password, please fill in both the password and password confirmation with the same value."
    expect_new_password_doesnt_work('barbaz')
  end

  scenario 'with unmatched password and confirmation' do
    fill_in "New password", :with => "barbaz"
    fill_in "Confirm new password", :with => "quxx"
    click_save_password_button

    should_be_on edit_account_settings_path
    expect_content "If you'd like to change your password, please fill in both the password and password confirmation with the same value."
    expect_new_password_doesnt_work('barbaz')
  end

  scenario "with underlength password" do
    fill_in "New password", :with => "quux"
    fill_in "Confirm new password", :with => "quux"
    click_save_password_button

    should_be_on edit_account_settings_path
    expect_content "Sorry, we couldn't set your password to that: it must have at least 6 characters."
    expect_new_password_doesnt_work('quux')
  end

def expect_new_password_works(new_password)
    click_link "Sign Out"
    signin_as @user, new_password
    should_be_on "/activity.html"
  end

  def expect_new_password_doesnt_work(new_password)
    click_link "Sign Out"
    signin_as @user, new_password
    should_be_on session_path
  end

  def click_save_password_button
    click_button "Save"
  end

end
