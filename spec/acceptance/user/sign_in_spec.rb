require 'acceptance/acceptance_helper'

feature 'Sign in' do
  let(:user) do
    u = FactoryGirl.create(:user)
    has_password(u, "foobar")
    u
  end

  scenario "from a user who's not signed up" do
    try_login_with "unknownguy@hotmail.com", "ungabunga"

    expect_content "Sorry, that's an invalid username or password."
    should_be_signed_out
  end

  scenario "entering the wrong password" do
    try_login_with user.email, "ungabunga"
    expect_content "Sorry, that's an invalid username or password."
    expect_value "session[email]", user.email
    should_be_signed_out
  end

  scenario "successfully" do
    try_login_with user.email, "foobar"

    expect_no_content "Signed in" # We got rid of that
    should_be_signed_in

    visit '/' # But we're still signed in...
    should_be_signed_in
    have_no_tile_manager_nav
  end

  scenario "redirects to the activity page" do
    try_login_with user.email, "foobar"

    should_be_on activity_path(format: 'html')
  end

  scenario "Signing in is case insensitive" do
    user.email.capitalize.should_not == user.email
    try_login_with user.email.capitalize, "foobar"
    should_be_signed_in
  end

  scenario "with SMS slug a.k.a username, case-insensitively" do
    user.sms_slug.should be_present
    user.sms_slug.capitalize.should_not == user.sms_slug

    try_login_with user.sms_slug, "foobar"
    should_be_signed_in

    sign_out_via_link # sign_out is taken by Clearance and doesn't work in this context

    try_login_with user.sms_slug.capitalize, "foobar"
    should_be_signed_in
  end


  def fill_in_password_fields(email_or_username, password)
    fill_in "session[email]", with: email_or_username
    fill_in "session[password]", with: password
  end

  def try_login_with(email_or_username, password)
    visit sign_in_path
    fill_in_password_fields(email_or_username, password)
    click_button "Log In"
  end


end
