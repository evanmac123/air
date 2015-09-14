require 'acceptance/acceptance_helper'

feature "Client admin opens tile stats" do
  let!(:demo) { FactoryGirl.create :demo }
  let!(:client_admin) { FactoryGirl.create :client_admin, demo: demo }

  def tile_cell(tile)
    "[data-tile_id='#{tile.id}']"
  end

  def open_stats(tile)
    visit client_admin_tiles_path(as: client_admin)
    within tile_cell(tile) do
      page.find(".tile_stats").click
    end
  end

  context "tile with empty stats" do
    before do
      @tile = FactoryGirl.create :tile, status: Tile::ACTIVE, demo: demo, question: "Is survey table present?"
      open_stats(@tile)
    end

    it "should show tile stats modal", js: true do
      expect_content "VIEWED AND INTERACTED"
      within "#tile_stats_modal" do
        page.find(".close-reveal-modal").click
      end
      expect_no_content "VIEWED AND INTERACTED"
    end

    it "should show empty graph stats", js: true do
      expect_content "0 UNIQUE VIEWS"
      expect_content "0 TOTAL VIEWS"
      expect_content "0 INTERACTIONS"
    end

    it "should not show surevy table", js: true do
      expect_no_content @tile.question
    end

    it "should show empty users table", js: true do
      expect_content "No users have completed this action yet."
    end
  end

  context "survey tile with completions" do
    def create_user_data_for_sorting(tile)
      @user_first_name = FactoryGirl.create(:user, demo: demo, name: '000')
      @user_last_name = FactoryGirl.create(:user, demo: demo, name: 'ZZZ')
      @user_first_email = FactoryGirl.create(:user, demo: demo, email: '000@gmail.com', name: 'First Email')
      @user_last_email = FactoryGirl.create(:user, demo: demo, email: 'zzz@gmail.com', name: 'Last Email')
      @user_most_views = FactoryGirl.create(:user, demo: demo, name: "Most Views")
      @user_least_views = FactoryGirl.create(:user, demo: demo, name: "Least Views")
      @user_first_completed = FactoryGirl.create(:user, demo: demo, name: "First Completed")
      @user_last_completed = FactoryGirl.create(:user, demo: demo, name: "Last Completed")

      FactoryGirl.create(:tile_completion, user: @user_first_name, tile: tile)
      FactoryGirl.create(:tile_completion, user: @user_last_name, tile: tile)
      FactoryGirl.create(:tile_completion, user: @user_first_email, tile: tile)
      FactoryGirl.create(:tile_completion, user: @user_last_email, tile: tile)
      FactoryGirl.create(:tile_completion, user: @user_most_views, tile: tile)
      FactoryGirl.create(:tile_completion, user: @user_least_views, tile: tile)
      FactoryGirl.create(:tile_completion, user: @user_first_completed, tile: tile, created_at: 10.years.ago)
      FactoryGirl.create(:tile_completion, user: @user_last_completed, tile: tile, created_at: 10.years.from_now)

      FactoryGirl.create(:tile_viewing, user: @user_first_name, tile: tile)
      FactoryGirl.create(:tile_viewing, user: @user_last_name, tile: tile)
      FactoryGirl.create(:tile_viewing, user: @user_first_email, tile: tile)
      FactoryGirl.create(:tile_viewing, user: @user_last_email, tile: tile)
      FactoryGirl.create(:tile_viewing, user: @user_most_views, tile: tile, views: 100)
      FactoryGirl.create(:tile_viewing, user: @user_least_views, tile: tile, views: 0)
      FactoryGirl.create(:tile_viewing, user: @user_first_completed, tile: tile)
      FactoryGirl.create(:tile_viewing, user: @user_last_completed, tile: tile)
    end

    before do
      @tile = FactoryGirl.create :tile, status: Tile::ACTIVE, demo: demo, question: "Is survey table present?"
      # @tile = FactoryGirl.create :tile, :active,
      #                             demo: demo,
      #                             question_type: Tile::SURVEY,
      #                             question: "Is survey table present?"

      create_user_data_for_sorting(@tile)
      50.times do |i|
        u = FactoryGirl.create(:user, demo: demo)
        FactoryGirl.create(:tile_completion, user: u, tile: @tile)
        FactoryGirl.create(:tile_viewing, user: u, tile: @tile)
      end
      open_stats(@tile)
    end

    it "should show column names in user table", js: true do
      expect_content "Name"
      expect_content "Email"
      expect_content "Views"
      expect_content "Answer"
      expect_content "Date"
    end
  end
end
