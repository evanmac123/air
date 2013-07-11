require 'acceptance/acceptance_helper'

feature 'client admin views tiles reports' do
  let(:admin) { FactoryGirl.create :client_admin }
  let(:demo)  { admin.demo  }

  # -------------------------------------------------

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  # -------------------------------------------------

  describe 'A no-tile message is displayed when there are no tiles' do
    before(:each) { visit client_admin_tiles_reports_path }

    it 'for Active tiles' do
      within(active_tab) { page.should contain('There are no active tiles') }
    end

    it 'for Archived tiles' do
      select_tab 'Archived'
      within(archive_tab) { page.should contain('There are no archived tiles') }
    end
  end

  describe 'Tile reports contain the correct information, and tiles appear in reverse-chronological order by creation-date' do
    # Chronologically-speaking, creating tiles "up" from 0 to 'nun_tiles' and then checking "down" from 'num_tiles' to 0
    let(:num_tiles) { 10 }

    let!(:claimed_users)   { FactoryGirl.create_list(:user, 99, :claimed, demo: demo) << admin }  # admin + 99 = 100
    let!(:unclaimed_users) { FactoryGirl.create_list :user, 50,           demo: demo }

    let!(:tiles) do
      num_tiles.times do |i|
        tile = FactoryGirl.create :tile, demo: demo, headline: "Tile #{i}", created_at: Time.now + i.days
        (i * 10).times { |j| FactoryGirl.create :tile_completion, tile: tile, user: claimed_users[j] }
      end
    end

    let(:expected_tile_table) do
      # No need to test for images as that is done in other tests; this is for reporting numbers
      # The numbers outside the arrays are the actual values of the last column
      # (In case we decide to change the displayed precision)
      [ ["Image", "Headline", "Total", "Percent claimed", "Percent all"],
        [  "",     "Tile 9",    "90",       "90.0%",          "60.0%"  ],  # 60
        [  "",     "Tile 8",    "80",       "80.0%",          "53.3%"  ],  # 53.333
        [  "",     "Tile 7",    "70",       "70.0%",          "46.7%"  ],  # 46.666
        [  "",     "Tile 6",    "60",       "60.0%",          "40.0%"  ],  # 40
        [  "",     "Tile 5",    "50",       "50.0%",          "33.3%"  ],  # 33.333
        [  "",     "Tile 4",    "40",       "40.0%",          "26.7%"  ],  # 26.666
        [  "",     "Tile 3",    "30",       "30.0%",          "20.0%"  ],  # 20
        [  "",     "Tile 2",    "20",       "20.0%",          "13.3%"  ],  # 13.333
        [  "",     "Tile 1",    "10",       "10.0%",          "6.7%"   ],  # 6.666
        [  "",     "Tile 0",    "0",        "0.0%",           "0.0%"   ]   # 0
      ]
    end

    it "for Active tiles" do
      demo.tiles.update_all status: Tile::ACTIVE

      visit client_admin_tiles_reports_path

      table_content('#active table').should == expected_tile_table
    end

    it "for Archived tiles" do
      demo.tiles.update_all status: Tile::ARCHIVE

      visit client_admin_tiles_reports_path
      select_tab 'Archived'

      table_content('#archive table').should == expected_tile_table
    end
  end
end