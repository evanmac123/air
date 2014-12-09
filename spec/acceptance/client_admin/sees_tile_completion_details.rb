require 'acceptance/acceptance_helper'

feature "sees tile completion details" do  
  let (:client_admin) { FactoryGirl.create :client_admin}
  let (:tile) {FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: client_admin.demo)}
  let (:survey_tile) {FactoryGirl.create(:survey_tile, status: Tile::ACTIVE, demo: client_admin.demo)}
  let (:user) {FactoryGirl.create :user, demo: client_admin.demo}
  let (:guest_user) {FactoryGirl.create :guest_user, demo: client_admin.demo}
  let(:user_first_name) {FactoryGirl.create(:user, demo: client_admin.demo, name: '000')}
  let(:user_last_name) {FactoryGirl.create(:user, demo: client_admin.demo, name: 'ZZZ')}
  let(:user_first_email) {FactoryGirl.create(:user, demo: client_admin.demo, email: '000@gmail.com')}
  let(:user_last_email) {FactoryGirl.create(:user, demo: client_admin.demo, email: 'zzz@gmail.com')}
  let(:user_first_joined) {FactoryGirl.create(:user, demo: client_admin.demo, name: "first joined", accepted_invitation_at: 10.years.ago)}
  let(:user_latest) {FactoryGirl.create(:user, demo: client_admin.demo)}

  context "tiles detail page" do
    before do 
      FactoryGirl.create(:tile_completion, tile: tile, user: user)
      visit client_admin_tiles_path(as: client_admin)
    end
    scenario "see link for completion report details for the tile" do
      #MAKE SURE that @suppress_tile_stats = false in controller
      page.should have_link '1 user', href: client_admin_tile_tile_completions_path(tile)
    end
  end
  context 'no one has completed the tile', js:true do
    before do
      visit client_admin_tile_tile_completions_path(tile, as: client_admin)
    end
    scenario "send ping" do
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      properties = {page_name: 'Tile More Info Page'}
      FakeMixpanelTracker.should have_event_matching('viewed page', properties)
    end
    scenario "not completed report should show no record found" do
      click_link 'show_completed'
      page.should have_css('.grid_no_record')
      page.find('.grid_no_record').should have_content 'There are no users that have completed this tile yet.'
    end
  end
  context "everyone has completed the tile", js: true do
    before do
      FactoryGirl.create(:tile_completion, user: client_admin, tile: tile)
      visit client_admin_tile_tile_completions_path(tile, as: client_admin)
    end    
    scenario "completed report should show no record found" do
      click_link 'show_not_completed'
      page.should have_css('.grid_no_record')
      page.find('.grid_no_record').should have_content 'Everyone has completed this tile!'
    end
  end
  context "tile reports page with data", js:true do
    before do
      100.times do
        u = FactoryGirl.create(:user, demo: client_admin.demo)
        FactoryGirl.create(:tile_completion, user: u, tile: tile)
      end
      FactoryGirl.create(:tile_completion, user: user_first_name, tile: tile)
      FactoryGirl.create(:tile_completion, user: user_last_name, tile: tile)
      FactoryGirl.create(:tile_completion, user: user_first_email, tile: tile)
      FactoryGirl.create(:tile_completion, user: user_last_email, tile: tile)
      FactoryGirl.create(:tile_completion, user: user_first_joined, tile: tile)
      visit client_admin_tile_tile_completions_path(tile, as: client_admin)
    end    
    scenario "breadcrumb saying Tiles and Completion Report" do
      # breadcrumb says: 'Tiles > Completion Report'
      page.find('.breadcrumbs').should have_content 'Tiles'
      page.find('.breadcrumbs').should have_content 'Completion Report'
    end
    scenario "top of the page has the headline from the tile I clicked" do
      #top of the page has the headline from the tile I clicked
      page.should have_content tile.headline
    end
    # I see There are two options: 'Completed: Yes' or 'No' (second button class style, selected state blue, not selected grey)
      
    # By default the "yes" option is selected.
    scenario "I see the column titles: Name, Email, Date, Joined" do
      # I see the column titles: Name, Email, Date, Joined (date = date completed, joined = yes or no)
      page.should have_content "NAME"
      page.should have_content "EMAIL"
      page.should have_content "DATE"
      page.should have_content "JOINED"
    end
    scenario "sees pagination at bottom" do
      # bottom has pagination 
      page.should have_selector('div .pagination') 
    end
    scenario "on click name, list should show name descending" do
      click_link 'Name'
      page.find('tbody tr:first td:first').should have_content('000')
      click_link 'Name'
      page.find('tbody tr:first td:first').should have_content('ZZZ')
    end
    scenario "on click email, list should show email descending" do
      click_link 'Email'
      page.all('tbody tr:first td')[1].should have_content('000@gmail.com')
      click_link 'Email'
      page.all('tbody tr:first td')[1].should have_content('zzz@gmail.com')
    end
    scenario "on click joined, list should show joined descending" do
      click_link 'Joined'
      page.find('tbody tr:first td:first').should have_content('first joined')
      page.all('tbody tr:first td')[3].should have_content('Yes')
      click_link 'Joined'
      page.find('tbody tr:first td:first').should have_content('James Earl Jones')
      page.all('tbody tr:first td')[3].should have_content('No')
    end
    #    scenario "should be sortable by date" do
    #      tile_completion_latest = FactoryGirl.create(:tile_completion, user: user_latest, tile: tile)
    #      click_link 'Date'
    #      debugger
    #      page.find('tbody tr:first .has_tip')['title'].should have_content(tile_completion_latest.strftime(Wice::Defaults::DATETIME_FORMAT))
    #    end
    context "clicking no should show users who have not completed the tiles", js: true do
      before do 
        FactoryGirl.create :user, demo: client_admin.demo
        visit client_admin_tile_tile_completions_path(tile, as: client_admin)
      end
      scenario "I see the column Name, Email and joined" do
        click_link 'show_not_completed'
        page.should have_content "NAME"
        page.should have_content "EMAIL"
        page.should have_content "JOINED"
      end
    end
    context "doesn't see summary table for not survey tile" do 
      before do
        FactoryGirl.create(:tile_completion, user: client_admin, tile: tile)
        visit client_admin_tile_tile_completions_path(tile, as: client_admin)
      end
      scenario "I don't see Summary header" do
        page.should_not have_content "Summary"
      end
    end
    context "sees summary table for survey tile" do 
      before do
        FactoryGirl.create(:tile_completion, user: client_admin, tile: survey_tile, answer_index: 0)
        visit client_admin_tile_tile_completions_path(survey_tile, as: client_admin)
      end
      scenario "I see summary header Summary" do
        page.should have_content "SUMMARY"
      end
      scenario "I see the column name Answer, Number, Percent" do
        page.should have_content "ANSWER"
        page.should have_content "NUMBER"
        page.should have_content "PERCENT"
      end
      scenario "I see answers in Summary table" do
        survey_tile.multiple_choice_answers.each do |answer| 
          page.find(".survey-chart-table").should have_content answer
        end
      end
    end
    context "sees data in summary table for survey tile" do
      before do
        for i in 1..100 do
          u = FactoryGirl.create(:user, demo: client_admin.demo)
          answer_index =  if i <= 30
            0
          elsif i <= 80
            1
          else
            2
          end
          FactoryGirl.create(:tile_completion, user: u, tile: survey_tile, answer_index: answer_index)
        end
        visit client_admin_tile_tile_completions_path(survey_tile, as: client_admin)
      end 
      scenario "I see number of people" do
        page.all(".survey-chart-table tr td.number")[0].should have_content "30"
        page.all(".survey-chart-table tr td.number")[1].should have_content "50"
        page.all(".survey-chart-table tr td.number")[2].should have_content "20"
      end
      scenario "I see percent of people" do
        page.all(".survey-chart-table tr td.percent")[0].should have_content "30.0%"
        page.all(".survey-chart-table tr td.percent")[1].should have_content "50.0%"
        page.all(".survey-chart-table tr td.percent")[2].should have_content "20.0%"
      end
    end
  end
end