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

  describe 'Tile reports contain the correct information, and appear in reverse-chronological order by activation/archived-date' do
    # Chronologically-speaking, creating tiles "up" from 0 to 'nun_tiles' and then checking "down" from 'num_tiles' to 0
    let(:num_tiles) { 10 }

    let!(:claimed_users)   { FactoryGirl.create_list(:user, 99, :claimed, demo: demo) << admin }  # admin + 99 = 100
    let!(:unclaimed_users) { FactoryGirl.create_list :user, 5,            demo: demo }

    let!(:tiles) do
      on_day '7/4/2013' do
        num_tiles.times do |i|
          awhile_from_now = Time.now + i.days
          tile = FactoryGirl.create :tile, demo: demo, headline: "Tile #{i}", created_at: awhile_from_now,
                                    activated_at: awhile_from_now, archived_at: awhile_from_now
          # Make it so that all odd tiles should be listed before all even ones, and that odd/even each should be sorted in descending order.
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
      [ ["Image", "Headline", "Completions", "% of participants"],
        [  "",     "Tile 9",      "90",           "90.0%"       ],
        [  "",     "Tile 7",      "70",           "70.0%"       ],
        [  "",     "Tile 5",      "50",           "50.0%"       ],
        [  "",     "Tile 3",      "30",           "30.0%"       ],
        [  "",     "Tile 1",      "10",           "10.0%"       ],
        [  "",     "Tile 8",      "80",           "80.0%"       ],
        [  "",     "Tile 6",      "60",           "60.0%"       ],
        [  "",     "Tile 4",      "40",           "40.0%"       ],
        [  "",     "Tile 2",      "20",           "20.0%"       ],
        [  "",     "Tile 0",      "0",            "0.0%"        ]
      ]
    end

    def initial_filename(tile_type)
      %r{#{tile_type}_tiles_report_#{Time.zone.now.to_s(:csv_file_date_stamp)}.csv}
    end

    context "Active tiles" do
      before(:each) do
        demo.tiles.update_all status: Tile::ACTIVE
        visit client_admin_tiles_reports_path
      end

      it 'website page content is correct' do
        table_content('#active table').should == expected_tile_table
      end

      it 'csv file name and content are correct' do
        on_day '7/4/2013' do
          click_link 'Download CSV'

          page.response_headers['Content-Type'].should =~ %r{text/csv}
          page.response_headers['Content-Disposition'].should =~ initial_filename('active')

          expected_csv = <<CSV
Headline,Status,Completions,% of participants
Tile 9,Active 9 days; since 7/13/2013,90,90.0%
Tile 7,Active 7 days; since 7/11/2013,70,70.0%
Tile 5,Active 5 days; since 7/9/2013,50,50.0%
Tile 3,Active 3 days; since 7/7/2013,30,30.0%
Tile 1,Active 1 day; since 7/5/2013,10,10.0%
Tile 8,Active 6 days; since 6/28/2013,80,80.0%
Tile 6,Active 8 days; since 6/26/2013,60,60.0%
Tile 4,Active 10 days; since 6/24/2013,40,40.0%
Tile 2,Active 12 days; since 6/22/2013,20,20.0%
Tile 0,Active 14 days; since 6/20/2013,0,0.0%
CSV
          page.body.gsub(/\n\n/, "\n").should == expected_csv  # Page body has pairs of newlines while here-doc has only one
        end
      end
    end

    context "Archived tiles" do
      before(:each) do
        demo.tiles.update_all status: Tile::ARCHIVE
        visit client_admin_tiles_reports_path
        select_tab 'Archived'
      end

      it 'website page content is correct' do
        table_content('#archive table').should == expected_tile_table
      end

      it 'csv file name and content are correct' do
        on_day '7/4/2013' do
          click_link 'Download CSV'

          page.response_headers['Content-Type'].should =~ %r{text/csv}
          page.response_headers['Content-Disposition'].should =~ initial_filename('archive')

          expected_csv = <<CSV
Headline,Status,Completions,% of participants
Tile 9,Active less than a minute. Deactivated 7/13/2013,90,90.0%
Tile 7,Active less than a minute. Deactivated 7/11/2013,70,70.0%
Tile 5,Active less than a minute. Deactivated 7/9/2013,50,50.0%
Tile 3,Active less than a minute. Deactivated 7/7/2013,30,30.0%
Tile 1,Active less than a minute. Deactivated 7/5/2013,10,10.0%
Tile 8,Active less than a minute. Deactivated 6/28/2013,80,80.0%
Tile 6,Active less than a minute. Deactivated 6/26/2013,60,60.0%
Tile 4,Active less than a minute. Deactivated 6/24/2013,40,40.0%
Tile 2,Active less than a minute. Deactivated 6/22/2013,20,20.0%
Tile 0,Active less than a minute. Deactivated 6/20/2013,0,0.0%
CSV
          page.body.gsub(/\n\n/, "\n").should == expected_csv  # Page body has pairs of newlines while here-doc has only one
        end
      end
    end
  end
end
