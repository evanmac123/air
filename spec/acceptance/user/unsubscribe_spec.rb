require 'acceptance/acceptance_helper'
include EmailHelper

feature "user unsubscribes" do
  before(:each) do
    @user = FactoryBot.create(:user, name: 'user Eckles')
    @token = EmailLink.generate_token(@user)
    @unsubscribe_url = email_unsubscribe_link(user: @user, email_type: "default", demo: @user.demo)
  end

  it "should unsubscribe the user" do
    visit @unsubscribe_url
    click_button 'Unsubscribe'
    expect(page).to have_content 'You have been unsubscribed.'

    expect(current_path).to eq(activity_path)
  end

  context "when user is unclaimed" do
    before do
      expect(@user).not_to be_claimed
    end

    it "should not have a link to the account preferences page" do
      visit @unsubscribe_url
      expect_no_content "change your contact preferences"
    end
  end
end
