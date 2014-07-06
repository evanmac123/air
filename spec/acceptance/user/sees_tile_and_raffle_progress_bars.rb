require 'acceptance/acceptance_helper'

def click_right_answer
  # This is a hack because all the animations we threw on the tile viewer
  # apparently confuse the shit out of poltergeist, and the claim that it
  # can wait for them to finish is a damned dirty lie. So we cheat and click
  # the hidden link that ACTUALLY triggers the Ajax request, while bypassing
  # animations.
  #page.find('.right_multiple_choice_answer').click
  page.find('.right_multiple_choice_answer').click
end

feature 'User sees progress bars' do
  before(:each) do
    @demo = FactoryGirl.create(:demo, :with_tickets, ticket_threshold: 10)
    @user = FactoryGirl.create(:user, :claimed, :with_phone_number, demo: @demo)
    @tile_3 = FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE, headline: "Tile the first", points: 15, demo: @demo)
    @tile_2 = FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE, headline: "Tile the second", points: 5, demo: @demo)
    @tile_1 = FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE, headline: "Tile the third", points: 13, demo: @demo)
  end

  context "tile progress and total progress" do
    before(:each) do
      visit tiles_path(as: @user)
    end
    it "are incremented after completing tile", js: true do
      tile_num = completed_tiles_number
      points = total_points

      click_right_answer
      visit tiles_path(as: @user)
      completed_tiles_number.should == tile_num + 1
      total_points.should == points + @tile_1.points
    end
  end

  context "raffle progress" do
    before(:each) do
      @raffle = @demo.raffle = FactoryGirl.create(:raffle, :live, demo: @demo)
      visit tiles_path(as: @user)
    end
    it "shows raffle new box on first enter", js: true do
      expect_content "New Raffle!"
      visit tiles_path(as: @user)
      expect_no_content "New Raffle!"
    end
    it "ping on first enter to new raffle", js: true do
      expect_content "New Raffle!"
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching("Saw Prize Modal",{ "action" => "Clicked Start"})
    end
    it "show raffle box on info raffle click", js: true do
      visit tiles_path(as: @user)
      click_raffle_info
      expect_content "Prize"
    end
    it "ping on info raffle click", js: true do
      visit tiles_path(as: @user)
      click_raffle_info
      expect_content "Prize"
      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching("Clicked Prize Info",{"action" => "Clicked Start"})
    end
    it "is encremented after completing tile", js: true do
      visit tiles_path(as: @user)
      old_progress = @user.reload.to_ticket_progress_calculator.points_towards_next_threshold
      expect_raffle_progress old_progress * 5
      click_right_answer
      visit tiles_path(as: @user)
      new_progress = @user.reload.to_ticket_progress_calculator.points_towards_next_threshold
      expect_raffle_progress new_progress * 5
    end
  end
end