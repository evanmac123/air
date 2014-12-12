require 'acceptance/acceptance_helper'

feature 'Sets logo url for board' do
  scenario 'does what it says' do
    admin = FactoryGirl.create(:site_admin)

    visit edit_admin_demo_path(admin.demo, as: admin)

    expected_logo_url = "http://www.example.com/globalthermonuclearwar.png"
    fill_in "Logo URL", with: expected_logo_url
    click_button "Update Game"
    page.find('#logo img')['src'].should == expected_logo_url
  end
end
