require 'acceptance/acceptance_helper'

feature 'Sets email mask for board' do
  scenario "via the basic settings page" do
    demo = FactoryGirl.create(:demo)
    expect(demo.custom_reply_email_name).to be_blank

    visit edit_admin_demo_path(demo, as: an_admin)
    fill_in "Email mask", with: "Awesomeville Corp"
    click_button "Update Game"

    expect(demo.reload.custom_reply_email_name).to eq("Awesomeville Corp")
  end
end
