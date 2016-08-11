require 'acceptance/acceptance_helper'

Capybara.javascript_driver = :selenium
feature "Guest user visits airbo" do
  before(:each) do
    @demo = FactoryGirl.create(:demo)
    @slug_path = "/ard/#{@demo.public_slug}"
    @slug_activity_path = "#{@slug_path}/activity"
    @slug_tiles_path = "#{@slug_path}/tiles"
  end

  context "first tile hint" do
    before do
      FactoryGirl.create(:tile, demo: @demo)
    end
    scenario "appears if there are no completions", js:true do
      visit @slug_path
      expect(page).to have_content("Click on the Tile to begin.")
      click_link 'Got it'
      expect(page).to have_no_content("Click on the Tile to begin.")
    end

    scenario "should not see first tile hint if user has completed tilese", js:true do
      UserIntro.any_instance.stubs(:displayed_first_tile_hint).returns true
      visit @slug_path
      expect(page).to have_no_content("Click on the Tile to begin.")
    end
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
