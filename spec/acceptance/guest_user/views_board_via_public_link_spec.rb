require 'acceptance/acceptance_helper'

def expect_bad_public_board_message
  expect_content "This board is currently private. Please contact support@hengage.com for assistance joining."
end

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

%w(
  /b/derp
  /b/derp/activity
  /b/derp/tiles
).each do |bad_path|
  feature "going to a nonexistent public link such as #{bad_path}" do
    it 'should give a helpful error' do
      visit bad_path
      expect_bad_public_board_message
    end
  end
end
