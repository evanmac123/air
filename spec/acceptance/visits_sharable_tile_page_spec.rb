require 'acceptance/acceptance_helper'

feature "visits sharable tile page" do
  include SignUpModalHelpers

  let!(:tile) { FactoryGirl.create(:multiple_choice_tile, is_sharable: true) }

  before(:each) do
    crank_dj_clear
    tile.reload
  end

  def show_register_form?
    true
  end

  shared_examples_for 'gets registration form' do |name, selector|
    scenario "when clicks #{name}", js: true do
      page.find(selector).click
      register_if_guest
    end
  end

  shared_examples_for "answers the tile" do
    scenario "should get feedback", js: true do
      click_link "Ham"
      expect_content "Sorry, that's not it. Try again!"

      click_link "Eggs"
      expect_content "Correct!"
    end
  end

  shared_examples_for "makes ping on board creation or signin" do
    scenario "should ping on create board", js: true do
      click_link "Create Board"
      expect_ping "Tile - Viewed", { "action" => "Clicked Create Board", "tile_id" => tile.id.to_s}, @user
    end

    scenario "should ping on sign in", js: true do
      click_link "Sign In"
      expect_ping "Tile - Viewed", { "action" => "Clicked Sign-in", "tile_id" => tile.id.to_s}, @user
    end
  end

  shared_examples_for "makes ping" do
    scenario "should ping on visiting page" do
      expect_ping "Tile - Viewed", { tile_type: "Public Tile", tile_id: tile.id}, @user
    end

    scenario "should ping on answering", js: true do
      click_link "Eggs"
      expect_ping "Tile - Viewed", { "action" => "Answered Question", "tile_id" => tile.id.to_s}, @user
    end

    scenario "should ping on logo", js: true do
      page.find(".go_home").click
      expect_ping "Tile - Viewed", { "action" => "Clicked Logo", "tile_id" => tile.id.to_s}, @user
    end
  end

  context "as Nobody" do
    before do
      @user = nil
      visit sharable_tile_path(tile)
    end

    it_should_behave_like "gets registration form", "create board button", "#save_progress_button"
    it_should_behave_like "answers the tile"
    it_should_behave_like "makes ping"
    it_should_behave_like "makes ping on board creation or signin"
  end

  it "should allow the user to see a shared tile in a private board" do
    private_board = FactoryGirl.create(:demo, is_public: false)
    tile = FactoryGirl.create(:multiple_choice_tile, is_sharable: true, demo: private_board)

    visit sharable_tile_path(tile)

    expect_no_content "This board is currently private"
    expect_content tile.headline
  end

  context "as User" do
    before do
      @user = a_regular_user
      visit sharable_tile_path(tile, as: @user)
    end

    it_should_behave_like "answers the tile"
    it_should_behave_like "makes ping"
  end

  context "as Client Admin" do
    before do
      @user = a_client_admin
      visit sharable_tile_path(tile, as: @user)
    end

    it_should_behave_like "answers the tile"
    it_should_behave_like "makes ping"
  end

  scenario "show 404 error for not sharable tile" do 
    tile2 = FactoryGirl.create :multiple_choice_tile
    visit sharable_tile_path(tile2)
    page.status_code.should be(404)
  end
end
