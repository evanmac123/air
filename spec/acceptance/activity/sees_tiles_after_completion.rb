# -*- coding: utf-8 -*-
require 'acceptance/acceptance_helper'
#FOR ACTIVITY PAGE
  #STARTED    "Move compete tile(s) to the end of the list of active tiles, with the last completed coming first in the list. All uncompleted tiles always stay before completed ones."
  #DONE       "In the board view, if a tile is complete by user, gray out picture via gradient overlay and place green checkmark in upper right hand corner (font awesome, fa-check-circle)"
#"If I completed tile 2 which was later deactivated by admin, then I would not see that tile in the list of 'active' tiles, but would see it in my history."
#"I complete all of my active tiles, and see my tile wall is entirely full of tiles that are grey and have a check-mark on them."
#I see latest completed tile before the rest of the completed tiles
#FOR TILE VIEWER
#"when I click on completed tiles, I am able to view the tile as well as move between other completed tiles"
#"when I click on completed tiles, I should see the tiles to be completed PLUS the tiles I completed when I entered the viewer"
#"with 5 tiles to be completed, when I click on tiles to be completed and complete 4/5 tiles, in the meanwhile admin adds a 6th tile, I should see 6 tiles when I click for next tile, 
#"when user is checking completed tiles, it should cycle through"
#"I complete all of my active tiles, and see a screen that says “you’ve completed all of your tiles.” I click the home button and see my tile wall is entirely full of tiles that are grey and have a check-mark on them."

feature "Sees tiles after completion" do
  context "on activity page" do
    let(:demo) {FactoryGirl.create :demo}
    let (:tile) {FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo)}
    let(:user) {FactoryGirl.create :user, demo: demo}
    context "sees completed tiles" do
      before do      
        FactoryGirl.create(:tile_completion, tile: tile, user: user)      
        visit activity_path(as: user)
      end
      scenario "shows completed tiles section" do
        page.should have_css('.completed')
      end
    end
    context "sees new tiles" do
      before do      
        FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo)
        visit activity_path(as: user)
      end
      scenario "shows not completed tiles section" do
        page.should_not have_selector('.completed')
      end
    end
    context "sees position of completed and not completed tiles" do
      before do
        2.times { FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo) }
        FactoryGirl.create(:tile_completion, tile: tile, user: user)
        visit activity_path(as: user)
      end
      scenario "should display completed tiles after new tiles" do
        page.should have_css('div.tile_thumbnail_image')
      end
    end
    context "sees tile completion history" do
      before do
        FactoryGirl.create(:tile, demo: demo)
        FactoryGirl.create(:tile_completion, tile: tile, user: user)
        visit activity_path(as: user)
      end
      scenario "should display tile in history even after it is deactivated" do
        page.should have_css('div#feed_wrapper')
      end
    end
  end
  context "on tile viewer" do
    let(:demo) {FactoryGirl.create :demo}
    let (:tile) {FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo)}
    let(:user) {FactoryGirl.create :user, demo: demo}
    context "clicks back button" do
      before do      
        FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo)
        FactoryGirl.create(:tile_completion, tile: tile, user: user)      
        visit tiles_path(as: user)
      end
      scenario "allows to see tile that was last completed" do
        page.should have_selector('a', 'clicked_right_answer')
      end
    end    
    context "clicks back button" do
      before do      
        FactoryGirl.create(:tile, status: Tile::ACTIVE, demo: demo)
        visit tiles_path(as: user)
      end
      scenario "allows to see tile that was not completed" do
        page.should have_selector('a', 'right_multiple_choice_answer')
      end      
    end
  end
end
