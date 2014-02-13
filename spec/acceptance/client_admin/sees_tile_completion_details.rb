require 'acceptance/acceptance_helper'

feature "sees tile completion details" do  
  let (:client_admin) { FactoryGirl.create :client_admin}
  let (:tile) {FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: client_admin.demo)}
  let (:user) {FactoryGirl.create :user, demo: client_admin.demo}
  let (:guest_user) {FactoryGirl.create :guest_user, demo: client_admin.demo}
  let(:user_first) {FactoryGirl.create(:user, demo: client_admin.demo, name: '000')}
  let(:user_last) {FactoryGirl.create(:user, demo: client_admin.demo, name: 'ZZZ')}
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
      2.times do
        u = FactoryGirl.create(:user, demo: client_admin.demo)
        FactoryGirl.create(:tile_completion, user: u, tile: tile)
      end
      FactoryGirl.create(:tile_completion, user: user_first, tile: tile)
      FactoryGirl.create(:tile_completion, user: user_last, tile: tile)
      visit client_admin_tile_tile_completions_path(tile, as: client_admin)
    end    
    scenario "breadcrumb saying Tiles and Completion Report" do
      # breadcrumb says: 'Tiles > Completion Report'
      page.find('.breadcrumbs').should have_content 'Tiles'
      page.find('.breadcrumbs').should have_content 'Completion Report'
    end
    scenario "top of the page has the headline from the tile I clicked" do
      #top of the page has the headline from the tile I clicked
      page.find('h3').should have_content tile.headline
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
      page.should have_selector('div', 'pagination') 
    end
    scenario "on click name, list should show name descending" do
      click_link 'Name'
      page.find('tbody tr:first td:first').should have_content('000')
      page.find('tbody tr:last td:first').should have_content('ZZZ')
    end
    scenario "should be sortable by date" do
      sleep 1
      tile_completion_latest = FactoryGirl.create(:tile_completion, user: user_latest, tile: tile)
      click_link 'Date'
      click_link 'Date'
      page.find('tbody tr:first').should have_content(tile_completion_latest.created_at.to_s)
    end
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
  end
end