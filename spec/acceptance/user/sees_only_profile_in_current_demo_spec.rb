require 'acceptance/acceptance_helper'

feature "User Sees Only Profile In Current Demo" do
  scenario "User sees only profile in current demo" do
    @user1 = FactoryGirl.create :claimed_user
    @user2 = FactoryGirl.create :claimed_user

    expect(@user1.demo).to_not eq(@user2.demo)

    has_password @user1, "foobar"
    signin_as @user1, "foobar"
    should_be_on activity_path

    visit user_path(@user2)
    expect(page).not_to have_content(@user2.email)
    expect(page.current_path).to eq(root_path)
  end
end
