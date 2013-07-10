require 'acceptance/acceptance_helper'

feature 'client admin can see tile reports' do
  let(:admin) { FactoryGirl.create :client_admin }
  let(:demo)  { admin.demo  }

  let!(:claimed_users)   { FactoryGirl.create_list(:user, 99, :claimed, demo: demo) << admin }
  let!(:unclaimed_users) { FactoryGirl.create_list :user, 50,           demo: demo }

  # -------------------------------------------------

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  # -------------------------------------------------

  # Chronologically speaking, creating tiles "up" from 0 to nun_tiles and then checking "down" from num_tiles to 0

  describe 'tiles appear in reverse-chronological order by creation-date' do
    it "'active' tiles" do
      num_tiles = 10

      num_tiles.times do |i|
        tile = FactoryGirl.create :tile, demo: demo, headline: "Tile #{i}", status: Tile::ACTIVE, created_at: Time.now + i.days
        (i * 10).times { |j| FactoryGirl.create :tile_completion, tile: tile, user: claimed_users[j] }
      end

      visit client_admin_tiles_reports_path

      tile_table = table_content '#active table'
      tile_table.each { |row| p "************ #{row}" }

      expected_tile_table = [ ["Image", "Headline", "Total", "Percent claimed", "Percent all"],
                              ["", "Tile 9", "90", "90.0%", "60.0%"],  # 60
                              ["", "Tile 8", "80", "80.0%", "53.3%"],  # 53.333
                              ["", "Tile 7", "70", "70.0%", "46.7%"],  # 46.666
                              ["", "Tile 6", "60", "60.0%", "40.0%"],  # 40
                              ["", "Tile 5", "50", "50.0%", "33.3%"],  # 33.333
                              ["", "Tile 4", "40", "40.0%", "26.7%"],  # 26.666
                              ["", "Tile 3", "30", "30.0%", "20.0%"],  # 20
                              ["", "Tile 2", "20", "20.0%", "13.3%"],  # 13.333
                              ["", "Tile 1", "10", "10.0%", "6.7%" ],  # 6.666
                              ["", "Tile 0", "0",  "0.0%",  "0.0%" ]   # 0
                            ]

      expected_tile_table.should == tile_table
    end

    #it "'archive' tiles" do
    #  tile_num = 9
    #  10.times { |i| FactoryGirl.create :tile, demo: demo, headline: "Tile #{i}", status: Tile::ARCHIVE, created_at: Time.now + i.days }
    #
    #  visit client_admin_tiles_reports_path
    #  tile_table = table_content '#archive table'
    #
    #  tile_table.each do |row|
    #    row.each do |col|
    #      col.should == "Tile #{tile_num}"
    #      tile_num -= 1
    #    end
    #  end
    #end
  end
end