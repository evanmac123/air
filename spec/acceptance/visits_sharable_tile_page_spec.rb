require 'acceptance/acceptance_helper'

feature "visits sharable tile page", js: true do
  include SignUpModalHelpers

  let!(:tile) { FactoryGirl.create(:multiple_choice_tile, is_sharable: true) }

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

  context "as Nobody" do
    before do
      @user = nil
      visit sharable_tile_path(tile)
    end

    it_should_behave_like "gets registration form", "create board button", "#save_progress_button"
    it_should_behave_like "answers the tile"
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
  end

  context "as Client Admin" do
    before do
      @user = a_client_admin
      visit sharable_tile_path(tile, as: @user)
    end

    it_should_behave_like "answers the tile"
  end

  scenario "show 404 error for not sharable tile" do
    tile2 = FactoryGirl.create :multiple_choice_tile
    visit sharable_tile_path(tile2)
    page.status_code.should be(404)
  end
end
