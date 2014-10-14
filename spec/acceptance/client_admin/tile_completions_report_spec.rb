require 'acceptance/acceptance_helper'

feature 'client admin views tile completions and non completions reports' do
  def download_link
    page.find("a.download_as_csv")
  end

  def report_name type = "tile"
    %r{#{type}_completions_report_#{DateTime.now.strftime("%d_%m_%y")}}
  end

  let!(:admin) { FactoryGirl.create :client_admin, email: "bo@example.com" }
  let!(:demo)  { admin.demo }
  let!(:tile)  { FactoryGirl.create :survey_tile, status: Tile::ACTIVE, demo: demo }
  let!(:users) do 
    for i in 1..10 do
      FactoryGirl.create :user, name: "j'ames#{i}", demo: demo, email: "j'ames#{i}@example.com"
    end
  end
  let!(:tile_completions) do
    demo.users.each_with_index do |user, i|
      next if i.even?
      FactoryGirl.create :tile_completion, tile: tile, user: user, answer_index: (i%3), created_at: Date::strptime("10/13/2014", "%m/%d/%Y")
    end
  end

  describe "Tile Completions Report" do
    scenario "csv name and content are correct"do
      visit client_admin_tile_tile_completions_path(tile, as: admin)
      download_link.click

      page.response_headers['Content-Type'].should =~ %r{text/csv}
      page.response_headers['Content-Disposition'].should =~ report_name

      expected_csv = <<CSV
Name,Email,Date,Answer,Joined?
j'ames9,j'ames9@example.com,10/13/2014,Ham,No
j'ames7,j'ames7@example.com,10/13/2014,Eggs,No
j'ames5,j'ames5@example.com,10/13/2014,A V8 Buick,No
j'ames3,j'ames3@example.com,10/13/2014,Ham,No
j'ames1,j'ames1@example.com,10/13/2014,Eggs,No
CSV
      page.body.should == expected_csv
    end
  end

  describe "Non Completions Report" do
    scenario "csv name and content are correct"do
      visit client_admin_tile_tile_completions_path(tile, as: admin)
      page.find(".not-completed").click
      download_link.click

      page.response_headers['Content-Type'].should =~ %r{text/csv}
      page.response_headers['Content-Disposition'].should =~ report_name("non")

      expected_csv = <<CSV
Name,Email,Joined?
Bo Diddley,bo@example.com,Yes
j'ames10,j'ames10@example.com,No
j'ames2,j'ames2@example.com,No
j'ames4,j'ames4@example.com,No
j'ames6,j'ames6@example.com,No
j'ames8,j'ames8@example.com,No
CSV
      page.body.should == expected_csv
    end
  end
end