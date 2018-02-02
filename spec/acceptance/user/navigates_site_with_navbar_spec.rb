require 'acceptance/acceptance_helper'

feature 'User navigates site with navbar', js: true do
  let(:site_admin) { FactoryBot.create(:site_admin) }

  {
    'Site admin' => "admin_path",
    'Settings'   => "edit_account_settings_path",
    'Sign Out'   => "sign_in_path",
    'Home'       => 'explore_path',
    'My Profile' => 'user_path(@joe)',
    'Find users' => 'users_path'
  }.each do |link_text, page_path_code|
    it "should have a working link to #{link_text}" do
      visit root_path(as: site_admin)
      find("#me_toggle").click
      within ".user_options" do
        click_link link_text
      end
      should_be_on eval(page_path_code)
    end
  end
end
