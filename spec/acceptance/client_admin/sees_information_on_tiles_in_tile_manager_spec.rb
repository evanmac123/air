require 'acceptance/acceptance_helper'

feature 'Sees helpful information in tile manager' do
  let (:demo)         { FactoryGirl.create :demo }
  let (:client_admin) { FactoryGirl.create :client_admin, demo: demo }

  def tile_cell(tile)
    "[data-tile_id='#{tile.id}']"  
  end

  def expect_total_views_count tile, count
    within tile_cell(tile) do
      expect_content "#{count} Total"
    end
  end

  def expect_unique_views_count tile, count
    within tile_cell(tile) do
      expect_content "#{count} Unique"
    end
  end

  def expect_completed_users_count(tile, expected_count)
    within tile_cell(tile) do
      within ".completions" do
        if expected_count == 1
          user_phrase = "1 user"
        else
          user_phrase = "#{expected_count} users"
        end
        expect_content "Completed: #{user_phrase}"
      end
    end
  end

  def expect_completed_users_percentage(tile, expected_percentage)
    within tile_cell(tile) do
      within ".completion_percentage" do
        expect_content "Completed: #{expected_percentage}% of joined users"
      end
    end
  end

  def complete_tile tile
    expect_content tile.headline
    page.find('.right_multiple_choice_answer').click
  end

  after do
    Timecop.return
  end

  context "for a tile in the archive that has never been activated", js: true do
    it "should say so" do
      tile = FactoryGirl.create(:tile, demo: demo, status: Tile::ARCHIVE)
      tile.activated_at.should be_nil
      tile.archived_at.should_not be_nil

      visit client_admin_tiles_path(as: client_admin)

      within tile_cell(tile) do
        expect_content "Never activated"
        expect_no_content "Deactivated:"
      end
    end
  end

  context "for a tile in the archive that was at one point active" do
    before do
      Timecop.travel(7.days)
      @tile = FactoryGirl.create(:tile, demo: demo, status: Tile::ARCHIVE, activated_at: 7.days.ago)

      visit client_admin_tiles_path(as: client_admin)
    end

    it "should show the length of time that it was active", js: true do
      within tile_cell(@tile) do
        expect_content "Active: 7 days"
      end
    end

    it "should show when it was deactivated" do
      within tile_cell(@tile) do
        expect_content "Deactivated: #{Date.today.strftime('%-m/%-d/%Y')}"
      end
    end
  end

  context "for a tile that is active" do
    context "info about activation" do
      before do
        Timecop.travel(7.days)
        @tile = FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE, activated_at: 7.days.ago, archived_at: 19.days.ago)

        visit client_admin_tiles_path(as: client_admin)
      end

      it "should show the length of time that it's been active", js: true do
        within "#{tile_cell(@tile)}.active" do
          expect_content "Active: 7 days"
        end
      end
    end

    context "info about views" do
      before do
        @tile1 = FactoryGirl.create(:multiple_choice_tile, demo: demo, status: Tile::ACTIVE, activated_at: 7.days.ago)
        @tile2 = FactoryGirl.create(:multiple_choice_tile, demo: demo, status: Tile::ACTIVE, activated_at: 7.days.ago)
      end

      it "should have no views initially" do
        visit client_admin_tiles_path(as: client_admin)

        expect_total_views_count @tile1, 0
        expect_total_views_count @tile2, 0

        expect_unique_views_count @tile1, 0
        expect_unique_views_count @tile2, 0
      end

      it "should count user's views when he completes and views tiles", js: true do
        #
        # => Completes tiles
        #
        visit tiles_path(as: client_admin)
        
        complete_tile @tile2
        complete_tile @tile1

        expect_content "Return to homepage"

        visit client_admin_tiles_path(as: client_admin)

        expect_total_views_count @tile1, 1
        expect_total_views_count @tile2, 1

        expect_unique_views_count @tile1, 1
        expect_unique_views_count @tile2, 1
        #
        # => Views tiles
        #
        visit tile_path(@tile2, as: client_admin)

        expect_content @tile2.headline
        show_next_tile

        expect_content @tile1.headline
        show_next_tile

        expect_content @tile2.headline

        visit client_admin_tiles_path

        expect_total_views_count @tile1, 2
        expect_total_views_count @tile2, 3

        expect_unique_views_count @tile1, 1
        expect_unique_views_count @tile2, 1
      end

      it "should count guest user's views when he views completed tiles", js: true do
        guest_user = a_guest_user
        #
        # => Completes tiles
        #
        visit public_tiles_path(public_slug: demo.public_slug, as: guest_user)
        
        complete_tile @tile2
        complete_tile @tile1

        expect_content "Return to homepage"
        #
        # => Views tiles
        #
        visit public_tile_path(id: @tile2, public_slug: demo.public_slug, as: guest_user)

        close_conversion_form

        expect_content @tile2.headline
        show_next_tile

        close_conversion_form

        expect_content @tile1.headline
        show_next_tile

        expect_content @tile2.headline

        visit client_admin_tiles_path(as: client_admin)

        expect_total_views_count @tile1, 2
        expect_total_views_count @tile2, 3

        expect_unique_views_count @tile1, 1
        expect_unique_views_count @tile2, 1
      end
    end
  end

  context "with information about completed tiles" do
    before do
      @tile_1 = FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE,  archived_at: 5.days.ago, activated_at: 2.days.ago)
      @tile_2 = FactoryGirl.create(:tile, demo: demo, status: Tile::ARCHIVE, archived_at: 5.days.ago, activated_at: 6.days.ago)
      @tile_3 = FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE,  archived_at: 5.days.ago, activated_at: 2.days.ago)
      @tile_4 = FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE,  archived_at: 5.days.ago, activated_at: 2.days.ago)

      1.times {FactoryGirl.create(:tile_completion, tile: @tile_1)}
      2.times {FactoryGirl.create(:tile_completion, tile: @tile_2)}
      3.times {FactoryGirl.create(:tile_completion, tile: @tile_3)}

      [@tile_1, @tile_2, @tile_3].each do |tile|
        tile.tile_completions.map(&:user).each {|user| user.add_board(demo.id)}
        tile.tile_completions.first.user.update_attributes(accepted_invitation_at: Time.now)
      end

      visit client_admin_tiles_path(as: client_admin)
    end

    it "such as the number of users who have completed the tile" do
      expect_completed_users_count(@tile_1, 1)
      expect_completed_users_count(@tile_2, 2)
      expect_completed_users_count(@tile_3, 3)
      expect_completed_users_count(@tile_4, 0)
    end

    it "such as the percentage of claimed users who have completed the tile" do
      expect_completed_users_percentage(@tile_1, "25.0")
      expect_completed_users_percentage(@tile_2, "50.0")
      expect_completed_users_percentage(@tile_3, "75.0")
      expect_completed_users_percentage(@tile_4, "0.0")
    end
  end
end
