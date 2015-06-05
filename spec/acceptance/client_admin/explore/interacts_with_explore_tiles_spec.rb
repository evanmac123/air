require 'acceptance/acceptance_helper'

feature "Interacts with tiles in explore page" do
  def click_first_thumbnail
    page.first('.explore_tile .headline a').click
  end

  it "by clicking on one and viewing it", js: true do
    FactoryGirl.create(:multiple_choice_tile, :public)
    visit explore_path(as: a_client_admin)
    click_first_thumbnail

    should_be_on explore_tile_preview_path(Tile.first)

    expect_supporting_content Tile.first.supporting_content
    expect_question Tile.first.question
    expect_content "99 POINTS"
    expect_answer 0, "Ham"
    expect_answer 1, "Eggs"
    expect_answer 2, "A V8 Buick"
  end

  it "pings when looking at a tile full-size", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, :public)
    visit explore_path(as: a_client_admin)

    crank_dj_clear
    FakeMixpanelTracker.clear_tracked_events

    click_first_thumbnail
    crank_dj_clear

    FakeMixpanelTracker.should have_event_matching('Tile - Viewed in Explore', {tile_id: tile.id})
  end

  it "rejects off-the-street-yahoos, guest users, and peons" do
    visit explore_path
    should_be_on sign_in_path

    visit explore_path(as: a_guest_user)
    should_be_on sign_in_path

    visit explore_path(as: a_regular_user)
    should_be_on activity_path
  end
end