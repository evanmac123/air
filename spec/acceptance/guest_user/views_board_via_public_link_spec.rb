require 'acceptance/acceptance_helper'

feature 'Views board via public link' do
  {
    '/b/aboard'          => '/b/aboard/activity',
    '/b/aboard/activity' => '/b/aboard/activity',
    '/b/aboard/tiles'    => '/b/aboard/tiles'
  }.each do |entry_path, expected_destination|
    context "to #{entry_path}" do
      scenario "ends up on #{expected_destination}" do
        FactoryGirl.create(:demo, public_slug: 'aboard')
        visit entry_path
        should_be_on expected_destination
      end
    end
  end

  scenario "but omitting to go through the public link first, gets redirected to signin--i.e. the existence of a public link doesn't mean you can just waltz in without it" do
    visit activity_path
    should_be_on sign_in_path
  end
end
