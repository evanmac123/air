require 'acceptance/acceptance_helper'

feature 'Tags on Explore' do
  def expect_only_headlines_in(tiles)
    valid_headlines = tiles.map(&:headline)
    page.all('.headline').map(&:text).each do |found_headline|
      valid_headlines.should include(found_headline)
    end
  end

  before do
    @tag_to_click = FactoryGirl.create(:tile_tag, title: "Click me")
    @other_tags = FactoryGirl.create_list(:tile_tag, 5)

    @tagged_tiles = FactoryGirl.create_list(:tile, 2, :public)
    @tagged_tiles.each {|tagged_tile| tagged_tile.tile_tags << @tag_to_click}

    @other_tagged_tiles = FactoryGirl.create_list(:tile, 2, :public)
    @other_tagged_tiles.each{|other_tagged_tile| other_tagged_tile.tile_tags = @other_tags}

    @untagged_tiles = FactoryGirl.create_list(:tile, 4, :public)
  end

  it "shows tiles only with the chosen tag when clicked" do
    visit tile_tag_show_explore_path(tile_tag: @tag_to_click.id, as: a_client_admin)

    @tagged_tiles.each {|tagged_tile| expect_content tagged_tile.headline}
    @other_tagged_tiles.each {|other_tagged_tile| expect_no_content other_tagged_tile.headline}
    @untagged_tiles.each {|untagged_tile| expect_no_content untagged_tile.headline}
  end

  it "respects the tag when See More is clicked", js: true do
    # This, plus the two above, makes 33 tiles total.
    31.times do
      tile = FactoryGirl.create(:tile, :public)
      tile.tile_tags << @tag_to_click
      @tagged_tiles << tile
    end

    visit tile_tag_show_explore_path(tile_tag: @tag_to_click.id, as: a_client_admin)

    expect_thumbnail_count 16, '.explore_tile'
    expect_only_headlines_in(@tagged_tiles)

    show_more_tiles_link.click
    expect_thumbnail_count 32, '.explore_tile'
    expect_only_headlines_in(@tagged_tiles)

    show_more_tiles_link.click
    expect_thumbnail_count 33, '.explore_tile'
    expect_only_headlines_in(@tagged_tiles)
  end

  it "pings when clicking a tag in the tile subjects section", js: true do
    visit explore_topic_path(@tag_to_click.topic, as: a_client_admin)
    within '.tags' do
      click_link 'Click me'
    end

    page.should have_content('Explore: Good Topic: Click me') # wait till load is done
    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear
    FakeMixpanelTracker.should have_event_matching('Explore Main Page', {action: 'Clicked Tile Subject Tag', tag: 'Click me'})
  end

  it "pings when clicking a tag on a tile", js: true do
    visit explore_path(as: a_client_admin)
    tag_name = nil
    within(page.first('.explore_tile')) do
      tag_link = page.first('li.tile_tag a')
      tag_name = tag_link.text

      tag_link.click
    end

    page.should have_content("Explore: Good Topic: #{tag_name}") # wait till load is done
    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear

    FakeMixpanelTracker.should have_event_matching('Explore Main Page', {action: 'Clicked Tag On Tile', tag: tag_name})
  end

  it "pings when clicking a tag on a tile in a later batch", js: true do
    19.times do
      tile = FactoryGirl.create(:tile, :public)
      tile.tile_tags << @tag_to_click
    end

    visit explore_path(as: a_client_admin)
    click_link 'More'

    crank_dj_clear
    FakeMixpanelTracker.clear_tracked_events

    within(page.all('.explore_tile')[11]) do
      click_link 'Click me'
    end

    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear
    FakeMixpanelTracker.should have_event_matching('Explore Main Page', {action: 'Clicked Tag On Tile', tag: 'Click me'})
  end

  it "pings when clicking a tag on a tile, on the topic page", js: true do
    visit tile_tag_show_explore_path(tile_tag: @tag_to_click, as: a_client_admin)
    within(page.first('.explore_tile .all_tile_tags')) do
      click_link "Click me"
    end

    page.should have_content('Explore: Good Topic: Click me') # wait till load is done
    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear
    FakeMixpanelTracker.should have_event_matching('Explore Topic Page', {action: 'Clicked Tag On Tile', tag: "Click me"})
  end

  it "pings when clicking a tag on a tile, on the topic page, in a later batch", js: true do
    19.times do
      tile = FactoryGirl.create(:tile, :public)
      tile.tile_tags << @tag_to_click
    end

    visit tile_tag_show_explore_path(tile_tag: @tag_to_click, as: a_client_admin)
    click_link 'More'

    crank_dj_clear
    FakeMixpanelTracker.clear_tracked_events

    within(page.all('.explore_tile')[19]) do
      click_link 'Click me'
    end

    crank_dj_clear
    FakeMixpanelTracker.should have_event_matching('Explore Topic Page', {action: 'Clicked Tag On Tile', tag: "Click me"})
  end

  it "pings when clicking a tile thumbnail on the topic page", js: true do
    visit tile_tag_show_explore_path(tile_tag: @tag_to_click, as: a_client_admin)
    page.first('.explore_tile .headline a').click

    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear
    FakeMixpanelTracker.should have_event_matching('Explore Topic Page', action: 'Tile Thumbnail Clicked')
  end

  it "pings when clicking a tile thumbnail on the topic page in a later batch", js: true do
    19.times do
      tile = FactoryGirl.create(:tile, :public)
      tile.tile_tags << @tag_to_click
    end

    visit tile_tag_show_explore_path(tile_tag: @tag_to_click, as: a_client_admin)
    click_link 'More'

    crank_dj_clear
    FakeMixpanelTracker.clear_tracked_events

    page.all('.explore_tile .headline a')[19].click

    crank_dj_clear
    FakeMixpanelTracker.should have_event_matching('Explore Topic Page', action: 'Tile Thumbnail Clicked')
  end
end
