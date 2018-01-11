require 'acceptance/acceptance_helper'
#NOTE This spec is no longer valid since the new onboarding doesn't require
#these steps
#TODO remove this conversion spec

feature 'Guest user converts from public board', js: true do
  it "creates a user and redirects them to activity_path" do
    board = FactoryBot.create(:demo, public_slug: "sluggg", is_public: true)
    visit public_board_path(public_slug: board.public_slug)
    page.find(".open_save_progress_form").click

    within "#guest_conversion_form" do
      page.fill_in "user[name]", with: "Airbo Name"
      page.fill_in "user[email]", with: "user1@email.com"
      page.fill_in "user[password]", with: "password"

      page.find("#guest_user_conversion_button").click
    end

    expect(current_path).to eq(activity_path)
    expect(User.count).to eq(1)
  end
end
