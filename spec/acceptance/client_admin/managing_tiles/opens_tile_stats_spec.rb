require 'acceptance/acceptance_helper'
include WaitForAjax

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
      @tile = FactoryGirl.create :tile, status: Tile::ACTIVE, demo: demo, question: "Is survey table present?"
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
        first_name.should == @user_first_name.name
      end

      it "should sort by name" do
        table_column("name").click
        first_name.should == @user_last_name.name
      end

      it "should sort by email" do
        table_column("email").click
        first_name.should == @user_first_email.name

        table_column("email").click
        first_name.should == @user_last_email.name
      end

      it "should sort by views" do
        table_column("views").click
        first_name.should == @user_least_views.name

        table_column("views").click
        first_name.should == @user_most_views.name
      end

      it "should sort by date" do
        table_column("date").click
        first_name.should == @user_first_completed.name

        table_column("date").click
        first_name.should == @user_last_completed.name
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
        first_name.should == "user40"
      end
    end

    context "user table types" do
      it "should show LIVE table by default" do
        u = FactoryGirl.create(:user, demo: demo, name: "LIVE user")
        FactoryGirl.create(:tile_completion, user: u, tile: @tile)
        FactoryGirl.create(:tile_viewing, user: u, tile: @tile)

        open_stats(@tile)

        first_name.should == "LIVE user"
      end

      it "should show INTERACTED table" do
        u = FactoryGirl.create(:user, demo: demo, name: "VIEWED AND INTERACTED user")
        FactoryGirl.create(:tile_completion, user: u, tile: @tile)
        FactoryGirl.create(:tile_viewing, user: u, tile: @tile)

        open_stats(@tile)
        select_grid_type ("Interacted")

        first_name.should == "VIEWED AND INTERACTED user"
      end

      it "should open VIEWED ONLY table" do
        u = FactoryGirl.create(:user, demo: demo, name: "VIEWED ONLY user")
        FactoryGirl.create(:tile_viewing, user: u, tile: @tile)

        open_stats(@tile)
        select_grid_type "Viewed only"

        first_name.should == "VIEWED ONLY user"
      end

      it "should open DIDN'T VIEW table" do
        u = FactoryGirl.create(:user, demo: demo, name: "a DIDN'T VIEW user")
        open_stats(@tile)

        select_grid_type "Didn't view"

        all_names.should include("a DIDN'T VIEW user")
      end

      it "should open ALL table" do
        u = FactoryGirl.create(:user, demo: demo, name: "ALL user")
        FactoryGirl.create(:tile_completion, user: u, tile: @tile)

        open_stats(@tile)
        select_grid_type "All"

        first_name.should == "ALL user"
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
      end

      it "should show all users initally" do
        within "#tile_stats_grid" do
          all_names.should == ["user0", "user1", "user2", "user3", "user4", "user5", "user6", "user7", "user8"]
        end
      end

      it "should filter by 'Yes' answer" do
        within "#tile_stats_grid" do
          page.first("td.answer_column", text: "Yes").click
          all_names.should == ["user0", "user3", "user6"]
        end
      end

      it "should filter by 'No' answer" do
        within "#tile_stats_grid" do
          page.first("td.answer_column", text: "No").click
          all_names.should == ["user1", "user4", "user7"]
        end
      end
    end

    context "survey table" do
      it "should show table" do
        open_stats(@tile)

        expect_content "DOY YOU LIKE STATS PAGE?"

        expect_content "Answer"
        expect_content "Users"
        expect_content "Percent"

        @tile.multiple_choice_answers.each do |answer|
          page.find(".survey-chart-table").should have_content answer
        end
      end

      it "should show correct data" do
        FactoryGirl.create(:tile_completion, tile: @tile, answer_index: 0)
        FactoryGirl.create(:tile_completion, tile: @tile, answer_index: 1)
        FactoryGirl.create(:tile_completion, tile: @tile, answer_index: 1)
        FactoryGirl.create(:tile_completion, tile: @tile, answer_index: 2)
        FactoryGirl.create(:tile_completion, tile: @tile, answer_index: 2)

        open_stats(@tile)
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
    page.find('.grid_types .custom.dropdown').click
    wait_for_ajax
    within '.grid_types .custom.dropdown.open' do
      page.find("li", text: type).click
      wait_for_ajax
    end
  end

  def tile_cell(tile)
    ".tile_thumbnail[data-tile-id='#{tile.id}']"
  end

  def open_stats(tile)
    visit client_admin_tiles_path(as: client_admin)
    wait_for_ajax
    within tile_cell(tile) do
      page.find(".tile_stats .unique_views").click
      wait_for_ajax
    end
    expect_content "UNIQUE VIEWS"
  end

  def first_name
    within "#tile_stats_modal.open" do
      page.all("td.name_column").first.text
    end
  end

  def all_names
    page.all("td.name_column").map(&:text)
  end

  def table_column name
    column_name = name == "date" ? name : (name + "_column")
    page.find("th.#{column_name} a")
  end

end
