require 'acceptance/acceptance_helper'

feature 'Carousel on Explore Tile Preview Page' do
  let(:admin) {FactoryGirl.create(:client_admin, voteup_intro_seen: true)}

  before(:each) do
    %w(Spam Fish).each do |title|
      FactoryGirl.create(:tile_tag, title: title)
    end

    @tags = TileTag.all

    0.upto(5) do |i|
      tag = i.even? ? @tags[0] : @tags[1]
      FactoryGirl.create(:multiple_choice_tile, :public, headline: "Tile#{i}", created_at: Time.now + i.day, tile_tags: [tag])
    end

    @tiles = Tile.order(:created_at)
  end

  context "if user comes from explore main page" do
    before(:each) do
      visit explore_path(as: admin)
      expect_content "Spam"
      click_link @tiles.first.headline
    end

    it "should show all tiles upwards", js: true do
      expect_content @tiles.first.headline
      1.upto(5) do |i|
        show_next_tile
        expect_content @tiles[i].headline
      end
    end

    it "should send ping on #next button click", js: true do
      show_next_tile

      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching('Explore page - Interaction', action: "Clicked arrow to next tile")
    end

    it "should send ping on #prev button click", js: true do
      show_previous_tile

      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching('Explore page - Interaction', action: "Clicked arrow to previous tile")
    end

    it "should move to next tile after clicking right answer", js: true do
      expect_content @tiles[0].headline
      page.find('.right_multiple_choice_answer').click
      expect_content @tiles[1].headline
    end

    it "should send ping on clicked right answer", js: true do
      page.find('.right_multiple_choice_answer').click

      FakeMixpanelTracker.clear_tracked_events
      crank_dj_clear
      FakeMixpanelTracker.should have_event_matching("Explore page - Interaction", "action" => 'Clicked Answer', 'tile_id' => @tiles[0].id.to_s)
    end
  end

  context "if user comes from explore topic page" do
    before(:each) do
      visit explore_path(as: admin)
      within page.find(".tags") do
        click_link @tags[0].title
      end
    end

    it "should show tiles with chosen tag upwards", js: true do
      click_link @tiles.first.headline
      expect_content @tiles.first.headline

      [2,4].each do |i|
        show_next_tile
        expect_content @tiles[i].headline
      end
    end

    it "should show tiles with chosen tag backwards", js: true do
      click_link @tiles.first.headline
      expect_content @tiles.first.headline

      [4,2].each do |i|
        show_previous_tile
        expect_content @tiles[i].headline
      end
    end

    it "should move to next tile after clicking right answer", js: true do
      click_link @tiles.first.headline
      expect_content @tiles.first.headline

      page.find('.right_multiple_choice_answer').click
      expect_content @tiles[2].headline
    end
  end
end
