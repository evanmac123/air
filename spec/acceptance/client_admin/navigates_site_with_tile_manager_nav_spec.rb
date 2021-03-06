require 'acceptance/acceptance_helper'

feature 'Client Admin navigates site with tile manager navbar' do
  context "When all items are opened" do
    before(:each) do
      demo = FactoryBot.create :demo
      @joe = FactoryBot.create(:client_admin, demo: demo, name: 'Joe')
      visit activity_path(as: @joe)
    end

    {
      'Explore' => "explore_path",
      'Edit'   => "client_admin_tiles_path",
      'Preview'   => "activity_path",
      'Share' => 'client_admin_share_path',
      'Reports' => 'client_admin_reports_path',
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
