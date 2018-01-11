require 'acceptance/acceptance_helper'

feature 'Sets email mask for board' do
  scenario "via the basic settings page" do
    demo = FactoryBot.create(:demo)
    expect(demo.custom_reply_email_name).to be_blank

    visit edit_admin_demo_path(demo, as: an_admin)
    fill_in "Custom reply email name", with: "Awesomeville Corp"
    click_button "Save"

    expect(demo.reload.custom_reply_email_name).to eq("Awesomeville Corp")
  end
end
