require 'acceptance/acceptance_helper'

feature 'Client Admin navigates site with tile manager navbar' do
  context "When all items are opened" do
    before(:each) do
      demo = FactoryGirl.create :demo, :with_turned_off_onboarding
      @joe = FactoryGirl.create(:client_admin, demo: demo, name: 'Joe')
      has_password(@joe, 'foobar')
      signin_as(@joe, 'foobar')
    end

    {
      # ONLY FOR SA
      # 'Explore' => "explore_path",
      # "Library" => "library_path",
      'Preview'   => "activity_path",
      'Edit'   => "client_admin_tiles_path",
      'Share' => 'client_admin_share_path',
      'Activity' => 'client_admin_path',
      'Prizes' => 'client_admin_prizes_path',
      'Users' => 'client_admin_users_path'
    }.each do |link_text, page_path_code|
      it "should have a working link to #{link_text}" do
        within tile_manager_nav do
          click_link link_text
        end
        should_be_on eval(page_path_code)
      end
    end
  end
end
