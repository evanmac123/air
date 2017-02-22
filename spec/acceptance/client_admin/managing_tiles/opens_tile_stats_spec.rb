require 'acceptance/acceptance_helper'

feature "Client admin opens tile stats", js: true, type: :feature do

  let!(:demo) { FactoryGirl.create :demo }
  let!(:client_admin) { FactoryGirl.create :client_admin, demo: demo }

  def create_user_data_for_sorting(tile)
    @user_first_name = FactoryGirl.create(:user, demo: demo, name: '000')
    @user_last_name = FactoryGirl.create(:user, demo: demo, name: 'ZZZ')
    @user_first_email = FactoryGirl.create(:user, demo: demo, email: '000@gmail.com', name: 'First Email')
    @user_last_email = FactoryGirl.create(:user, demo: demo, email: 'zzz@gmail.com', name: 'Last Email')
    @user_most_views = FactoryGirl.create(:user, demo: demo, name: "Most Views")
    @user_least_views = FactoryGirl.create(:user, demo: demo, name: "Least Views")
    @user_first_completed = FactoryGirl.create(:user, demo: demo, name: "First Completed")
    @user_last_completed = FactoryGirl.create(:user, demo: demo, name: "Last Completed")

    FactoryGirl.create(:tile_completion, user: @user_first_completed, tile: tile, created_at: 10.years.ago)
    FactoryGirl.create(:tile_completion, user: @user_first_name, tile: tile)
    FactoryGirl.create(:tile_completion, user: @user_last_name, tile: tile)
    FactoryGirl.create(:tile_completion, user: @user_first_email, tile: tile)
    FactoryGirl.create(:tile_completion, user: @user_last_email, tile: tile)
    FactoryGirl.create(:tile_completion, user: @user_most_views, tile: tile)
    FactoryGirl.create(:tile_completion, user: @user_least_views, tile: tile)
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


  context "tile with empty stats" do
    before do
      @tile = FactoryGirl.create :tile, status: Tile::ACTIVE, demo: demo, question: "Is survey table present?", correct_answer_index: 0
      open_stats(@tile)
    end

    it "should show tile stats modal" do
      within "#tile_stats_modal.open" do
        expect_content "0 UNIQUE VIEWS"
      end
    end

    it "should show empty graph stats" do
      expect_content "0 UNIQUE VIEWS"
      expect_content "0 TOTAL VIEWS"
      expect_content "0 INTERACTIONS"
    end

    it "should not show surevy table" do
      expect_no_content @tile.question
    end

    it "should show empty users table" do
      expect_content "No users have viewed or interacted with Tiles."
    end
  end

  context "tile with completions" do
    before do
      @tile = FactoryGirl.create :survey_tile,
                                  demo: demo,
                                  question: "Doy you like stats page?",
                                  multiple_choice_answers: ["Yes", "No", "A V8 Buick"]
    end

    #TODO Make sure these assertions first_name == ... are the best way to do
    #these tests.

    context "sorting in user table" do
      before do
        create_user_data_for_sorting(@tile)
        open_stats(@tile)
      end

      it "should show column names" do
        expect_content "Name"
        expect_content "Email"
        expect_content "Views"
        expect_content "Answer"
        expect_content "Date"
      end

      it "should intialy sorted by name asc" do
        expect(first_name).to eq(@user_first_name.name)
      end

      it "should sort by email" do
        table_column("email").click
        expect(first_name).to eq(@user_first_email.name)

        table_column("email").click
        expect(first_name).to eq(@user_last_email.name)
      end

      it "should sort by views" do
        table_column("views").click
        expect(first_name).to eq(@user_least_views.name)

        table_column("views").click
        expect(first_name).to eq(@user_most_views.name)
      end

      it "should sort by date" do
        table_column("date").click
        expect(first_name).to eq(@user_first_completed.name)

        table_column("date").click
        expect(first_name).to eq(@user_last_completed.name)
      end
    end

    context "pagination in user table" do
      before do
        50.times do |i|
          u = FactoryGirl.create(:user, demo: demo, name: "user#{i.to_s.rjust(2,'0')}")
          FactoryGirl.create(:tile_completion, user: u, tile: @tile)
          FactoryGirl.create(:tile_viewing, user: u, tile: @tile)
        end
        open_stats(@tile)
      end

      it "should have pagination" do
        within "tfoot" do
          expect_content "1 2 3 ... 5"
        end
      end

      it "should paginate" do
        within "tfoot" do
          click_link "5"
        end
        expect(first_name).to eq("user40")
      end
    end

    context "user table types", broken: true do
      # TODO: These tests fail randomly.
      it "should show LIVE table by default" do
        u = FactoryGirl.create(:user, demo: demo, name: "LIVE user")
        FactoryGirl.create(:tile_completion, user: u, tile: @tile)
        FactoryGirl.create(:tile_viewing, user: u, tile: @tile)

        open_stats(@tile)
        expect_tile_headline(@tile)

        expect(first_name).to eq("LIVE user")
      end

      it "should show INTERACTED table" do
        u = FactoryGirl.create(:user, demo: demo, name: "VIEWED AND INTERACTED user")
        FactoryGirl.create(:tile_completion, user: u, tile: @tile)
        FactoryGirl.create(:tile_viewing, user: u, tile: @tile)

        open_stats(@tile)
        expect_tile_headline(@tile)
        select_grid_type ("Interacted")
        expect(first_name).to eq("VIEWED AND INTERACTED user")
      end

      it "should open VIEWED ONLY table" do
        u = FactoryGirl.create(:user, demo: demo, name: "VIEWED ONLY user")
        FactoryGirl.create(:tile_viewing, user: u, tile: @tile)

        open_stats(@tile)
        expect_tile_headline(@tile)
        select_grid_type "Viewed only"

        expect(first_name).to eq("VIEWED ONLY user")
      end

      it "should open DIDN'T VIEW table" do
        FactoryGirl.create(:user, demo: demo, name: "a DIDN'T VIEW user")
        open_stats(@tile)

        expect_tile_headline(@tile)
        select_grid_type "Didn't view"
        expect(all_names.include?("a DIDN'T VIEW user")).to eq(true)
      end

      it "should open ALL table" do
        u = FactoryGirl.create(:user, demo: demo, name: "ALL user")
        FactoryGirl.create(:tile_completion, user: u, tile: @tile)

        open_stats(@tile)
        expect_tile_headline(@tile)
        select_grid_type "All"
        expect(first_name).to eq("ALL user")
      end
    end

    context "filtering by answer" do
      before do
        9.times do |i|
          u = FactoryGirl.create(:user, demo: demo, name: "user#{i}")
          FactoryGirl.create(:tile_completion, user: u, tile: @tile, answer_index: i%3)
          FactoryGirl.create(:tile_viewing, user: u, tile: @tile)
        end

        open_stats(@tile)
        expect_tile_headline(@tile)
      end

      it "should show all users initally" do
        within "#tile_stats_grid" do
          expect(all_names).to eq(["user0", "user1", "user2", "user3", "user4", "user5", "user6", "user7", "user8"])
        end
      end

      it "should filter by 'Yes' answer" do
        within "#tile_stats_grid" do
          page.first("td.answer_column", text: "Yes").click
          expect(page).to have_no_css("td.answer_column", text: "No")
          expect(page).to have_no_css("td.answer_column", text: "A V8 Buick")
          expect(all_names).to eq(["user0", "user3", "user6"])
        end
      end

      it "should filter by 'No' answer" do
        within "#tile_stats_grid" do
          page.first("td.answer_column", text: "No").click
          expect(page).to have_no_css("td.answer_column", text: "Yes")
          expect(page).to have_no_css("td.answer_column", text: "A V8 Buick")
          expect(all_names).to eq(["user1", "user4", "user7"])
        end
      end
    end

    context "survey table" do
      it "should show table" do
        open_stats(@tile)

        expect_tile_headline(@tile)
        expect_content "DOY YOU LIKE STATS PAGE?"
        expect_content "Answer"
        expect_content "Users"
        expect_content "Percent"

        @tile.multiple_choice_answers.each do |answer|
          expect(page.find(".survey-chart-table")).to have_content answer
        end
      end

      it "should show correct data" do
        FactoryGirl.create(:tile_completion, tile: @tile, answer_index: 0)
        FactoryGirl.create(:tile_completion, tile: @tile, answer_index: 1)
        FactoryGirl.create(:tile_completion, tile: @tile, answer_index: 1)
        FactoryGirl.create(:tile_completion, tile: @tile, answer_index: 2)
        FactoryGirl.create(:tile_completion, tile: @tile, answer_index: 2)

        open_stats(@tile)
        expect_tile_headline(@tile)
       within  ".survey-chart-table" do
         users = page.all("tr td.users")
         expect(users[0]).to have_content "1"
         expect(users[1]).to have_content "2"
         expect(users[2]).to have_content "2"

         percents = page.all("tr td.percent")
         expect(percents[0]).to have_content "20.0%"
         expect(percents[1]).to have_content "40.0%"
         expect(percents[2]).to have_content "40.0%"
       end
      end
    end
  end

  def select_grid_type type
    page.find('.grid_types').click

    within '.custom.dropdown.open' do
      page.find("li", text: type).click
    end
  end

  def tile_cell(tile)
    ".tile_thumbnail[data-tile-id='#{tile.id}']"
  end

  def open_stats(tile)
    visit client_admin_tiles_path(as: client_admin)

    within tile_cell(tile) do
      page.find(".tile_stats .unique_views").click
    end
  end

  def first_name
    within "#tile_stats_modal.open" do
      page.all("td.name_column").first.text
    end
  end

  def all_names
    page.all("td.name_column").map(&:text)
  end

  def expect_tile_headline tile
    within ".title_block" do
      expect(page).to have_content(tile.headline)
    end
  end

  def table_column name
    column_name = name == "date" ? name : (name + "_column")
    page.find("th.#{column_name} a")
  end
end
