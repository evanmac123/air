require 'acceptance/acceptance_helper'

feature 'Sees helpful dates in tile manager' do
  let (:demo)         { FactoryGirl.create :demo }
  let (:client_admin) { FactoryGirl.create :client_admin, demo: demo }

  def tile_cell(tile)
    "td[data-tile_id='#{tile.id}']"  
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
      click_link "Archived"

      within tile_cell(tile) do
        expect_content "Never activated"
        expect_no_content "Deactivated"
      end
    end
  end

  context "for a tile in the archive that was at one point active" do
    before do
      Timecop.travel(7.days)
      @tile = FactoryGirl.create(:tile, demo: demo, status: Tile::ARCHIVE, activated_at: 7.days.ago)

      visit client_admin_tiles_path(as: client_admin)
      click_link "Archived"
    end

    it "should show the length of time that it was active", js: true do
      within tile_cell(@tile) do
        expect_content "Active 7 days"
      end
    end

    it "should show when it was deactivated" do
      within tile_cell(@tile) do
        expect_content "Deactivated #{Date.today.strftime('%-m/%-d/%Y')}"
      end
    end
  end

  context "for a tile that is active" do
    before do
      Timecop.travel(7.days)
      @tile = FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE, activated_at: 7.days.ago, archived_at: 19.days.ago)

      visit client_admin_tiles_path(as: client_admin)
      page.find("a[href='#active']").click
    end

    it "should show the length of time that it's been active", js: true do
      within "#{tile_cell(@tile)}.active" do
        expect_content "Active 7 days"
      end
    end

    it "should show when it was activated" do
      within "#{tile_cell(@tile)}.active" do
        expect_content "since #{7.days.ago.strftime('%-m/%-d/%Y')}"
      end
    end
  end

  context "in the digest tab" do
    it "should not show any of these handy dates", js: true do
      FactoryGirl.create(:tile, demo: demo, status: Tile::ACTIVE, archived_at: 5.days.ago, activated_at: 2.days.ago)
      visit client_admin_tiles_path(as: client_admin)
      click_link "Digest email"

      expect_no_content "Active 2 days"
      expect_no_content "since"
    end
  end
end
