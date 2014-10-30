require 'acceptance/acceptance_helper'

feature 'client admin views tiles reports' do
  let(:admin) { FactoryGirl.create :client_admin }
  let(:demo)  { admin.demo  }

  def download_links
    page.all("a", text: "Download stats")
  end

  def click_download_active_link
    download_links.first.click
  end

  def click_download_archive_link
    download_links.last.click
  end

  describe 'Tile reports contain the correct information, and appear in reverse-chronological order by activation/archived-date' do
    # Chronologically-speaking, creating tiles "up" from 0 to 'nun_tiles' and then checking "down" from 'num_tiles' to 0
    let(:num_tiles) { 10 }

    let!(:claimed_users)   { FactoryGirl.create_list(:user, 99, :claimed, demo: demo) << admin }  # admin + 99 = 100
    let!(:unclaimed_users) { FactoryGirl.create_list :user, 5,            demo: demo }

    let!(:tiles) do
      on_day '7/4/2013' do
        positions = [0, 5, 1, 6, 2, 7, 3, 8, 4, 9]
        num_tiles.times do |i|
          awhile_from_now = Time.now + i.days
          tile = FactoryGirl.create :tile, demo: demo, headline: "Tile , #{i}", created_at: awhile_from_now,
                                    activated_at: awhile_from_now, archived_at: awhile_from_now, position: positions[i]

          if i.even?
            awhile_ago = tile.created_at - 2.weeks
            tile.update_attributes(activated_at: awhile_ago, archived_at: awhile_ago)
          end

          (i * 10).times { |j| FactoryGirl.create :tile_completion, tile: tile, user: claimed_users[j] }
        end
      end
    end

    let(:expected_tile_table) do
      # No need to test for images as that is done in other tests; this is for reporting numbers
      # CSV processing initially barfed on commas in headlines. Easiest way to test the fix is to stick a comma in all headlines.
      [ ["Image", "Headline", "Completions", "% of participants"],
        [  "",     "Tile , 9",      "90",           "90.0%"       ],
        [  "",     "Tile , 7",      "70",           "70.0%"       ],
        [  "",     "Tile , 5",      "50",           "50.0%"       ],
        [  "",     "Tile , 3",      "30",           "30.0%"       ],
        [  "",     "Tile , 1",      "10",           "10.0%"       ],
        [  "",     "Tile , 8",      "80",           "80.0%"       ],
        [  "",     "Tile , 6",      "60",           "60.0%"       ],
        [  "",     "Tile , 4",      "40",           "40.0%"       ],
        [  "",     "Tile , 2",      "20",           "20.0%"       ],
        [  "",     "Tile , 0",      "0",            "0.0%"        ]
      ]
    end

    def initial_filename(tile_type)
      %r{#{tile_type}_tiles_report_#{Time.zone.now.to_s(:csv_file_date_stamp)}.csv}
    end

    context "Active tiles" do
      it 'csv file name and content are correct' do
        on_day '7/4/2013' do
          demo.tiles.update_all status: Tile::ACTIVE
          visit client_admin_tiles_path(as: admin)

          click_download_active_link

          page.response_headers['Content-Type'].should =~ %r{text/csv}
          page.response_headers['Content-Disposition'].should =~ initial_filename('active')

          expected_csv = <<CSV
Headline,Status,Completions,% of participants
\"Tile , 9\",Active: 9 days Since: 7/13/2013,90,90.0%
\"Tile , 7\",Active: 7 days Since: 7/11/2013,70,70.0%
\"Tile , 5\",Active: 5 days Since: 7/9/2013,50,50.0%
\"Tile , 3\",Active: 3 days Since: 7/7/2013,30,30.0%
\"Tile , 1\",Active: 1 day Since: 7/5/2013,10,10.0%
\"Tile , 8\",Active: 6 days Since: 6/28/2013,80,80.0%
\"Tile , 6\",Active: 8 days Since: 6/26/2013,60,60.0%
\"Tile , 4\",Active: 10 days Since: 6/24/2013,40,40.0%
\"Tile , 2\",Active: 12 days Since: 6/22/2013,20,20.0%
\"Tile , 0\",Active: 14 days Since: 6/20/2013,0,0.0%
CSV
          page.body.should == expected_csv
        end
      end
    end

    context "Archived tiles" do
      it 'csv file name and content are correct' do
        on_day '7/4/2013' do
          demo.tiles.update_all status: Tile::ARCHIVE
          visit client_admin_tiles_path(as: admin)
          click_download_archive_link

          page.response_headers['Content-Type'].should =~ %r{text/csv}
          page.response_headers['Content-Disposition'].should =~ initial_filename('archive')

          expected_csv = <<CSV
Headline,Status,Completions,% of participants
\"Tile , 9\",Active: less than a minute Deactivated: 7/13/2013,90,90.0%
\"Tile , 7\",Active: less than a minute Deactivated: 7/11/2013,70,70.0%
\"Tile , 5\",Active: less than a minute Deactivated: 7/9/2013,50,50.0%
\"Tile , 3\",Active: less than a minute Deactivated: 7/7/2013,30,30.0%
\"Tile , 1\",Active: less than a minute Deactivated: 7/5/2013,10,10.0%
\"Tile , 8\",Active: less than a minute Deactivated: 6/28/2013,80,80.0%
\"Tile , 6\",Active: less than a minute Deactivated: 6/26/2013,60,60.0%
\"Tile , 4\",Active: less than a minute Deactivated: 6/24/2013,40,40.0%
\"Tile , 2\",Active: less than a minute Deactivated: 6/22/2013,20,20.0%
\"Tile , 0\",Active: less than a minute Deactivated: 6/20/2013,0,0.0%
CSV
          page.body.should == expected_csv
        end
      end
    end
  end
end
