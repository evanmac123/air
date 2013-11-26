require 'acceptance/acceptance_helper'

feature 'Sees helpful information in tile manager' do
  let (:demo)         { FactoryGirl.create :demo }
  let (:client_admin) { FactoryGirl.create :client_admin, demo: demo }

  def tile_cell(tile)
    "td[data-tile_id='#{tile.id}']"  
  end

  def expect_completed_users_count(tile, expected_count)
    within tile_cell(tile) do
      within ".completions" do
        if expected_count == 1
          user_phrase = "1 user"
        else
          user_phrase = "#{expected_count} users"
        end
        expect_content "Completed by #{user_phrase}"
      end
    end
  end

  def expect_completed_users_percentage(tile, expected_percentage)
    within tile_cell(tile) do
      within ".completion_percentage" do
        expect_content "Completed by #{expected_percentage}% of joined users"
      end
    end
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

    it "should show when it was activated" do
      within "#{tile_cell(@tile)}.active" do
        expect_content "Since: #{7.days.ago.strftime('%-m/%-d/%Y')}"
      end
    end
  end

  context "in the digest tab" do
    it "should not show any of these handy dates", js: true do
      pending "TO BE MOVED ONTO ITS OWN PAGE"
      FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE, archived_at: 5.days.ago, activated_at: 2.days.ago)
      visit client_admin_tiles_path(as: client_admin)
      click_link "Digest email"

      expect_no_content "Active: 2 days"
      expect_no_content "Since:"
    end
  end

  context "with numerical information" do
    before do
      @tile_1 = FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE,  archived_at: 5.days.ago, activated_at: 2.days.ago)
      @tile_2 = FactoryGirl.create(:tile, demo: demo, status: Tile::ARCHIVE, archived_at: 5.days.ago, activated_at: 6.days.ago)
      @tile_3 = FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE,  archived_at: 5.days.ago, activated_at: 2.days.ago)
      @tile_4 = FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE,  archived_at: 5.days.ago, activated_at: 2.days.ago)

      1.times {FactoryGirl.create(:tile_completion, tile: @tile_1)}
      2.times {FactoryGirl.create(:tile_completion, tile: @tile_2)}
      3.times {FactoryGirl.create(:tile_completion, tile: @tile_3)}

      [@tile_1, @tile_2, @tile_3].each do |tile|
        tile.tile_completions.map(&:user).each {|user| user.update_attributes(demo_id: demo.id)}
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
