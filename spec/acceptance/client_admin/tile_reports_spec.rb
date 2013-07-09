require 'acceptance/acceptance_helper'

feature 'client admin can see tile reports' do
  let(:admin) { FactoryGirl.create :client_admin }
  let(:demo)  { admin.demo  }

  # -------------------------------------------------

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  # -------------------------------------------------

  # In both cases, creating tiles "up" from 0 to 9 and then checking "down" from 9 to 0

  describe 'tiles appear in reverse-chronological order by creation-date' do
    it "'active' tiles" do
      tile_num = 9
      10.times { |i| FactoryGirl.create :tile, demo: demo, headline: "Tile #{i}", created_at: Time.now + i.days }

      visit client_admin_tiles_reports_path
      tile_table = table_content '#active table'

      # todo maybe simplify this: just put numbers for headline => [ %w(9 8 7), %w(6 5 4), ...].should == tile_table
      # todo probably not; will probably switch this check to "col.should have_text(~~~)" because other stuff will be there

      # todo okay, everything's changed ; ALSO: need to spec "no active/archive tiles" message ***

      tile_table.each do |row|
        row.each do |col|
          col.should == "Tile #{tile_num}"
          tile_num -= 1
        end
      end
    end

    it "'archive' tiles" do
      tile_num = 9
      10.times { |i| FactoryGirl.create :tile, demo: demo, headline: "Tile #{i}", status: Tile::ARCHIVE, created_at: Time.now + i.days }

      visit client_admin_tiles_reports_path
      tile_table = table_content '#archive table'

      tile_table.each do |row|
        row.each do |col|
          col.should == "Tile #{tile_num}"
          tile_num -= 1
        end
      end
    end
  end
end