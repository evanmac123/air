require 'acceptance/acceptance_helper'

feature "Client admin copies parent board" do
  include WaitForAjax

  def reveal_text
    "All Tiles have been copied to your board's Drafts section."
  end

  def default_persistent_message
    "Airbo is an interactive communication tool. Get started by clicking on a tile. Interact and answer questions to earn points."
  end

  def tile_selector
    ".tile_thumbnail:not(.placeholder_tile)"
  end

  def completed_tile_selector
    ".tile_thumbnail:not(.placeholder_tile).completed"
  end

  let(:client_admin) { an_admin }
  let(:demo) { client_admin.demo }
  let(:parent_demo) { FactoryGirl.create(:demo, :parent) }

  context "on the Explore page" do
    before do
      @parent_demos = [parent_demo] + FactoryGirl.create_list(:demo, 5, :parent)
      @simple_demos = [demo] + FactoryGirl.create_list(:demo, 5)
      visit explore_path(as: client_admin)
    end

    it "should show parent demos" do
      within ".parent_boards" do
        @parent_demos.each do |board|
          expect_content board.name
        end

        @simple_demos.each do |board|
          expect_no_content board.name
        end
      end
    end
  end

  context "in the parent board", js:true do
    before do
      @tiles = FactoryGirl.create_list :multiple_choice_tile, 4, :active, demo: parent_demo
      @draft_tiles = FactoryGirl.create_list :multiple_choice_tile, 2, :draft, demo: parent_demo
      @archived_tiles = FactoryGirl.create_list :multiple_choice_tile, 2, :archived, demo: parent_demo


      UserIntro.any_instance.stubs(:displayed_first_tile_hint).returns(true)
      crank_dj_clear
    end

    context "activity page" do
      it "should not show archived tiles that were completed by user" do
        at = @archived_tiles.first
        FactoryGirl.create :tile_completion, user: client_admin, tile: at

        visit activity_path(board_id: parent_demo, as: client_admin)
        expect_no_content at.headline

        page.all(tile_selector).count.should == 4
      end

      it "should always show persistent message" do
        visit activity_path(board_id: parent_demo, as: client_admin)
        expect_content default_persistent_message

        visit activity_path(board_id: parent_demo, as: client_admin)
        expect_content default_persistent_message
      end
    end

    context "copy board button" do
      before do
        visit activity_path(board_id: parent_demo, as: client_admin)
      end

      it "should have copy button" do
        within "header" do
          page.should have_link "Copy"
        end
      end

      it "should copy posted tiles from parent to drafts in current demo", js: true do
        click_link "Copy"
        wait_for_ajax

        expect_content reveal_text
        demo.reload.draft_tiles.map(&:headline).should == parent_demo.active_tiles.map(&:headline)
        (demo.tiles.map(&:headline) & @draft_tiles.map(&:headline) + @archived_tiles.map(&:headline)).should be_empty
      end
    end

    context "tiles page" do
      before do
        FactoryGirl.create :tile_completion, tile: parent_demo.active_tiles.first, user: client_admin
      end

      it "should allow tile carousel and should reset completions if user comes by link from explore", js: true do
        # no completed tiles though we have tc in db
        visit activity_path(board_id: parent_demo, as: client_admin)
        page.all(completed_tile_selector).count.should == 0
        page.all(tile_selector).count.should == 4
        # we created this user for parent board
        parent_board_user = client_admin.parent_board_users.first

        page.all(tile_selector + " a").first.click

        # complete 2 tiles
        [0, 1].each do |i|
          tile = parent_demo.active_tiles[i]
          page.find(".tile_headline").text.should == tile.headline
          page.find(".right_multiple_choice_answer").click

          wait_for_ajax
          # it's saved for parent_board_user
          tc = TileCompletion.last
          tc.tile.should == tile
          tc.user.should == parent_board_user
        end

        # have 2 completed tiles on activity page
        visit activity_path(board_id: parent_demo, as: client_admin)
        page.all(completed_tile_selector).count.should == 2

        # watch completed tiles
        page.all(completed_tile_selector + " a").first.click
        [1, 0, 1].each do |i|
          tile = parent_demo.active_tiles[i]
          page.find(".tile_headline").text.should == tile.headline
          show_next_tile

          wait_for_ajax
        end

        # now complete last 2 tiles
        visit activity_path(board_id: parent_demo, as: client_admin)
        page.all(tile_selector + " a").first.click
        [2, 3].each do |i|
          tile = parent_demo.active_tiles[i]
          page.find(".tile_headline").text.should == tile.headline
          page.find(".right_multiple_choice_answer").click

          wait_for_ajax
          tc = TileCompletion.last
          tc.tile.should == tile
          tc.user.should == parent_board_user
        end
        click_link "Return to homepage"
        page.all(completed_tile_selector).count.should == 4

        # use link from explore. it resets completions
        visit parent_board_path(parent_demo, as: client_admin)
        page.all(completed_tile_selector).count.should == 0
      end
    end
  end
end
