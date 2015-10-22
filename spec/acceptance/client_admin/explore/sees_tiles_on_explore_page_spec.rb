require 'acceptance/acceptance_helper'

feature 'Sees tiles on explore page' do
  it "should show only tiles that are public and active or archived" do
    FactoryGirl.create_list(:tile, 2, :public)
    FactoryGirl.create(:tile, headline: "I do not appear in public")
    FactoryGirl.create(:tile, :public, status: Tile::ARCHIVE)

    visit explore_path(as: a_client_admin)
    expect_thumbnail_count 3, '.explore_tile'
    page.should_not have_content "I do not appear in public"
  end

  it "should have a working \"Show More\" button", js: true do
    FactoryGirl.create_list(:tile, 47, :public)
    visit explore_path(as: a_client_admin)
    expect_thumbnail_count 16, '.explore_tile'

    # These "sleep"s are a terrible hack, but I haven't gotten any of the
    # saner ways to get Poltergeist to wait for the AJAX request to work yet.
    show_more_tiles_link.click
    sleep 5
    expect_thumbnail_count 32, '.explore_tile'

    show_more_tiles_link.click
    sleep 5
    expect_thumbnail_count 47, '.explore_tile'
  end

  it "should ping when the more-tiles button is clicked", js: true do
    FactoryGirl.create_list(:tile, 20, :public)
    visit explore_path(as: a_client_admin)

    crank_dj_clear
    FakeMixpanelTracker.clear_tracked_events

    show_more_tiles_link.click
    sleep 5
    crank_dj_clear
    FakeMixpanelTracker.should have_event_matching('Explore Topic Page', action: 'Clicked See More')
  end

  it "should see information about creators for tiles that have them" do
    other_board = FactoryGirl.create(:demo, name: "The Board You've All Been Waiting For")
    creator = FactoryGirl.create(:client_admin, name: "John Q. Public", demo: other_board)
    tile = FactoryGirl.create(:tile, :public, creator: creator)
    creation_date = Date.parse("2013-05-01")
    tile.update_attributes(created_at: creation_date.midnight)

    begin
      Timecop.travel(Chronic.parse("2014-05-01"))
      visit explore_path(as: a_client_admin)

      expect_content "John Q. Public"
    ensure
      Timecop.return
    end
  end

  # FIXME use on topic page
  # context "by picking tagged ones" do
  #   it "lists tags that have active or archived tiles on the explore page in alpha order" do
  #     %w(Spam Fish Cheese Groats Bouillabase).each do |title|
  #       FactoryGirl.create(:tile_tag, title: title)
  #     end
  #
  #     tags = TileTag.all
  #
  #     tags[0,2].each do |tile_tag|
  #       tile = FactoryGirl.create(:tile, :public, status: Tile::ACTIVE)
  #       tile.tile_tags << tile_tag
  #     end
  #
  #     tags[2,3].each do |tile_tag|
  #       tile = FactoryGirl.create(:tile, :public, status: Tile::ARCHIVE)
  #       tile.tile_tags << tile_tag
  #     end
  #
  #
  #     visit explore_path(as: a_client_admin)
  #     expect_content "Bouillabase Cheese Fish Groats Spam"
  #   end
  #
  #   it "omits tags that have no active or archived public tiles on the explore page" do
  #     %w(Spam Fish Cheese Groats Bouillabase).each do |title|
  #       FactoryGirl.create(:tile_tag, title: title)
  #     end
  #
  #     %w(Nope None Nil).each do |title|
  #       tag = FactoryGirl.create(:tile_tag, title: title)
  #       tile = FactoryGirl.create(:tile)
  #       tile.tile_tags << tag
  #     end
  #
  #     visit explore_path(as: a_client_admin)
  #     %w(Spam Fish Cheese Groats Bouillabase).each {|title| expect_no_content title}
  #     %w(Nope None Nil).each {|title| expect_no_content title}
  #   end
  #
  # end

  context "when clicking through a tile" do
    before do
      @tile = FactoryGirl.create(:tile, :public)
    end

    it "pings" do
      visit explore_path(as: a_client_admin)
      page.first('.explore_tile .headline a').click

      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching('Explore Main Page', {action: "Tile Thumbnail Clicked"})
    end

    it "pings when clicking through a tile in a later batch", js: true do
      FactoryGirl.create_list(:tile, 19, :public)
      visit explore_path(as: a_client_admin)
      3.times { click_link 'More' }

      page.all('.explore_tile .headline a')[19].click

      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching('Explore Main Page', {action: "Tile Thumbnail Clicked"})
    end
  end

  context "when clicking the \"Explore\" link to go back to the main explore page from a topic page" do
    it "should ping" do
      tile_tag = FactoryGirl.create(:tile_tag)
      visit tile_tag_show_explore_path(tile_tag: tile_tag.id, as: a_client_admin)

      within('.explore_section') { click_link "Explore" }

      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear

      FakeMixpanelTracker.should have_event_matching('Explore Topic Page', action: 'Back To Explore')
    end
  end

  context "when answering a tile in the preview page" do
    it "should ping", js: true do
      tile = FactoryGirl.create(:multiple_choice_tile, :public)
      admin = FactoryGirl.create(:client_admin, voteup_intro_seen: true, share_link_intro_seen: true)
      visit explore_tile_preview_path(tile.id, as: admin)
      click_link 'Eggs'

      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear

      FakeMixpanelTracker.should have_event_matching('Explore page - Interaction', "action" => 'Clicked Answer', 'tile_id' => tile.id.to_s)
    end
  end
end
