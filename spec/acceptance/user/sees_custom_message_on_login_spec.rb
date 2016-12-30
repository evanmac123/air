require 'acceptance/acceptance_helper'

feature "User Sees Custom Message On Login" do

  scenario "User sees a custom message on login" do
    demo = FactoryGirl.create :demo, :login_announcement => "Eat Yr Fuckin Raisins"
    user = FactoryGirl.create :user, :demo => demo
    has_password(user, 'foobar')

    signin_as user, "foobar"
    expect(page).to have_content("Eat Yr Fuckin Raisins")

    visit "/activity"
    expect(page).not_to have_content("Eat Yr Fuckin Raisins")
  end
end
