require 'acceptance/acceptance_helper'
feature "Guest user visits airbo" do
  before(:each) do
    @demo = FactoryGirl.create(:demo)
    @slug_path = "/ard/#{@demo.public_slug}"
    @slug_activity_path = "#{@slug_path}/activity"
    @slug_tiles_path = "#{@slug_path}/tiles"
  end

  scenario 'successfully via any valid public link', js:true do
    {
      @slug_path =>  @slug_activity_path,
      @slug_activity_path =>  @slug_activity_path,
      @slug_tiles_path =>  @slug_tiles_path,
    }.each do |entry_path, expected_destination|
      visit entry_path
      should_be_on expected_destination
    end
  end

  scenario "sees error when arriving via invalid board link" do

    %w(/ard/derp /ard/derp/activity /ard/derp/tiles)
      .each do|bad_path|
      visit bad_path
      expect_bad_public_board_message
    end
  end

  scenario "sees error when arriving via non public link" do
    board = FactoryGirl.create(:demo, is_public: false)

    visit public_board_path(board.public_slug)
    expect_bad_public_board_message

    visit public_activity_path(board.public_slug)
    expect_bad_public_board_message

    visit public_tiles_path(board.public_slug)
    expect_bad_public_board_message
  end

  def expect_bad_public_board_message
    expect_content "This board is currently private. Please contact support@airbo.com for assistance joining."
  end
end
