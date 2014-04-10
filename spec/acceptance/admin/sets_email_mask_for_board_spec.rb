require 'acceptance/acceptance_helper'

feature 'Sets email mask for board' do
  scenario "via the basic settings page" do
    demo = FactoryGirl.create(:demo)
    demo.custom_reply_email_name.should be_blank

    visit edit_admin_demo_path(demo, as: an_admin)
    fill_in "Email mask", with: "Awesomeville Corp"
    click_button "Update Game"

    demo.reload.custom_reply_email_name.should == "Awesomeville Corp"
  end
end
