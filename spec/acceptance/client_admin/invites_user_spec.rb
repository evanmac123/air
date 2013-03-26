require 'acceptance/acceptance_helper'

feature 'Invites user' do
  it "from the edit page" do
    user = FactoryGirl.create(:user)
    client_admin = FactoryGirl.create(:client_admin, demo: user.demo)
    visit edit_client_admin_user_path(user, as: client_admin)

    user.should_not be_invited
    click_link "Send an invite"

    should_be_on edit_client_admin_user_path(user)
    user.reload.should be_invited
    expect_content "OK, we've just sent #{user.name} an invitation."
  end
end
