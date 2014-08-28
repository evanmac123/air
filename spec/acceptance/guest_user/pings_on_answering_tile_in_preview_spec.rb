require 'acceptance/acceptance_helper'

feature "Guest user answering a tile in preview" do
  it "should send the appropriate ping", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, :public)

    visit explore_tile_preview_path(id: tile.id)
    close_voteup_intro

    crank_dj_clear
    FakeMixpanelTracker.clear_tracked_events

    click_link "Eggs"
    page.should have_content("Correct!") # to let Ajax settle
    crank_dj_clear

    FakeMixpanelTracker.should have_event_matching("Explore page - Interaction", "action" => 'Clicked Answer', user_type: 'guest', 'tile_id' => tile.id.to_s)
  end
end
