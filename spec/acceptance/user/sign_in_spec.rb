require 'acceptance/acceptance_helper'

feature 'Sign in' do
  let(:user) do
    u = FactoryBot.create(:user)
    has_password(u, "foobar")
    u
  end

  context 'javascript sign in modal', js: true do
    scenario "from a user who's not signed up" do
      try_login_with "unknownguy@hotmail.com", "ungabunga"

      expect_content "Sorry, that's an invalid username or password."
      should_be_signed_out
    end

    scenario "entering the wrong password" do
      try_login_with user.email, "ungabunga"
      expect_content "Sorry, that's an invalid username or password."
      expect_value "session[email]", ""
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

      should_be_on activity_path
    end

    scenario "Signing in is case insensitive" do
      expect(user.email.capitalize).to_not eq(user.email)
      try_login_with user.email.capitalize, "foobar"
      should_be_signed_in
    end
  end

  def fill_in_password_fields(email_or_username, password)
    fill_in "session[email]", with: email_or_username
    fill_in "session[password]", with: password
  end

  def try_login_with(email_or_username, password)
    visit '/?sign_in=true'
    fill_in_password_fields(email_or_username, password)
    click_button "Sign In"
  end
end
