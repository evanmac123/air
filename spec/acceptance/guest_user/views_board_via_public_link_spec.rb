require 'acceptance/acceptance_helper'

def expect_bad_public_board_message
  expect_content "This board is currently private. Please contact support@airbo.com for assistance joining."
end

feature 'Views board via public link' do
  {
    '/ard/aboard'          => '/ard/aboard/activity',
    '/ard/aboard/activity' => '/ard/aboard/activity',
    '/ard/aboard/tiles'    => '/ard/aboard/tiles'
  }.each do |entry_path, expected_destination|
    context "to #{entry_path}" do
      scenario "ends up on #{expected_destination}" do
        FactoryGirl.create(:demo, public_slug: 'aboard')
        visit entry_path
        should_be_on expected_destination
      end
    end
  end
end

%w(
  /ard/derp
  /ard/derp/activity
  /ard/derp/tiles
).each do |bad_path|
  feature "going to a nonexistent public link such as #{bad_path}" do
    it 'should give a helpful error' do
      visit bad_path
      expect_bad_public_board_message
    end
  end
end

feature "going to a board that's not public" do
  it "should give a helpful error" do
    board = FactoryGirl.create(:demo, is_public: false)

    visit public_board_path(board.public_slug)
    expect_bad_public_board_message

    visit public_activity_path(board.public_slug)
    expect_bad_public_board_message

    visit public_tiles_path(board.public_slug)
    expect_bad_public_board_message
  end
end

