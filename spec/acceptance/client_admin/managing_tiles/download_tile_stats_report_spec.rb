require 'acceptance/acceptance_helper'

feature "Client admin downloads tile stats" do

  let!(:demo) { FactoryGirl.create :demo }
  let!(:client_admin) { FactoryGirl.create :client_admin, demo: demo }
  let!(:tile) do
    FactoryGirl.create :survey_tile,
                        demo: demo,
                        question: "Doy you like stats page?",
                        multiple_choice_answers: ["Yes", "No", "A V8 Buick"]
  end

  def download_link table
    client_admin_tile_tile_stats_grids_path(
      grid_type: table,
      tile_id: tile.id,
      tile_stats_grid: {"export"=>"csv"},
      as: client_admin
    )
  end

  def report_name
    %r{tile_stats_report_#{DateTime.now.strftime("%d_%m_%y")}}
  end

  def make_table_record name, email, views = nil, answer_index = nil, date_str = nil
    u = FactoryGirl.create(:user, demo: demo, name: name, email: email)
    FactoryGirl.create(:tile_viewing, user: u, tile: tile, views: views) if views
    if answer_index && date_str
      date = Date::strptime(date_str, "%d/%m/%Y")
      FactoryGirl.create(:tile_completion, user: u, tile: tile, answer_index: answer_index, created_at: date)
    end
  end

  before do
    make_table_record "VI User1", "vi1@gmail.com", 3, 0, "20/09/15"
    make_table_record "VI User2", "vi2@gmail.com", 10, 1, "20/08/15"

    make_table_record "VO User1", "vo1@gmail.com", 5
    make_table_record "VO User2", "vo2@gmail.com", 8

    make_table_record "DV User1", "dv1@gmail.com"
    make_table_record "DV User2", "dv2@gmail.com"
  end

  it "should download" do
    visit download_link("viewed_and_interacted")

    page.response_headers['Content-Type'].should =~ %r{text/csv}
    page.response_headers['Content-Disposition'].should =~ report_name
  end

  it "should download 'Viewed and Interacted' report" do
    visit download_link("viewed_and_interacted")

    expected_data = <<CSV
Name,Email,Views,Answer,Date
VI User1,vi1@gmail.com,3,Yes,9/20/0015
VI User2,vi2@gmail.com,10,No,8/20/0015
CSV
    page.body.should == expected_data
  end

  it "should download 'Viewed Only' report" do
    visit download_link("viewed_only")

    expected_data = <<CSV
Name,Email,Views,Answer,Date
VO User1,vo1@gmail.com,5,-,-
VO User2,vo2@gmail.com,8,-,-
CSV
    page.body.should == expected_data
  end

  it "should download 'Didnt view' report" do
    visit download_link("not_viewed")

    expected_data = <<CSV
Name,Email,Views,Answer,Date
Bo Diddley,darth_4@sunni.ru,-,-,-
DV User1,dv1@gmail.com,-,-,-
DV User2,dv2@gmail.com,-,-,-
CSV
    page.body.should == expected_data
  end

  it "should download 'All' report" do
    visit download_link("all")

    expected_data = <<CSV
Name,Email,Views,Answer,Date
Bo Diddley,darth_5@sunni.ru,-,-,-
DV User1,dv1@gmail.com,-,-,-
DV User2,dv2@gmail.com,-,-,-
VI User1,vi1@gmail.com,3,Yes,9/20/0015
VI User2,vi2@gmail.com,10,No,8/20/0015
VO User1,vo1@gmail.com,5,-,-
VO User2,vo2@gmail.com,8,-,-
CSV
    page.body.should == expected_data
  end
end
