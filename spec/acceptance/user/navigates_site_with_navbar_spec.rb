require 'acceptance/acceptance_helper'

feature 'User navigates site with navbar' do
  before(:each) do
    @joe = FactoryGirl.create(:site_admin, name: 'Joe')
    has_password(@joe, 'foobar')
    signin_as(@joe, 'foobar')
  end

  {
    'Site admin' => "admin_path",
    'Admin'      => "client_admin_path",
    'Settings'   => "edit_account_settings_path",
    'Sign Out'   => "sign_in_path",
    'Dashboard'       => 'activity_path',
    'My Profile' => 'user_path(@joe)',
    'Directory'  => 'users_path',
    'Help'       => 'faq_path'
  }.each do |link_text, page_path_code|
    it "should have a working link to #{link_text}" do
      click_link link_text
      should_be_on eval(page_path_code)
    end
  end
end
