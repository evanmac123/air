require 'acceptance/acceptance_helper'

feature 'Sees tiles on explore page' do
  def expect_only_headlines_in(tiles)
    valid_headlines = tiles.map(&:headline)
    page.all('.headline').map(&:text).each do |found_headline|
      valid_headlines.should include(found_headline)
    end
  end

  it "should show only tiles that are public and active" do
    FactoryGirl.create_list(:tile, 2, :public)
    FactoryGirl.create(:tile, headline: "I do not appear in public")
    FactoryGirl.create(:tile, is_public: true, status: Tile::ARCHIVE, headline: "Nor do I appear in public")

    visit explore_path(as: a_client_admin)
    expect_thumbnail_count 2
    page.should_not have_content "I do not appear in public"
  end

  it "should have a working \"Show More\" button", js: true do
    FactoryGirl.create_list(:tile, 15, :public)
    visit explore_path(as: a_client_admin)
    expect_thumbnail_count 8

    # These "sleep"s are a terrible hack, but I haven't gotten any of the
    # saner ways to get Poltergeist to wait for the AJAX request to work yet.
    show_more_tiles_link.click
    sleep 5
    expect_thumbnail_count 12

    show_more_tiles_link.click
    sleep 5
    expect_thumbnail_count 15
  end

  it "should see information about creators for tiles that have them" do
    other_board = FactoryGirl.create(:demo, name: "The Board You've All Been Waiting For")
    creator = FactoryGirl.create(:client_admin, name: "John Q. Public", demo: other_board)
    tile = FactoryGirl.create(:tile, is_public: true, creator: creator)
    creation_date = Date.parse("2013-05-01")
    tile.update_attributes(created_at: creation_date.midnight)

    visit explore_path(as: a_client_admin)

    expect_content "John Q. Public, The Board You've All Been Waiting For"
    expect_content "May 1, 2013"
  end

  context "by picking tagged ones" do
    it "lists tags that have tiles on the explore page in alpha order" do
      %w(Spam Fish Cheese Groats Bouillabase).each do |title|
        FactoryGirl.create(:tile_tag, title: title)
      end

      2.times do
        TileTag.all.each do |tile_tag|
          tile = FactoryGirl.create(:tile, :public)
          tile.tile_tags << tile_tag
        end
      end

      visit explore_path(as: a_client_admin)
      expect_content "Bouillabase Cheese Fish Groats Spam"
    end

    it "omits tags that have no active public tiles on the explore page" do
      %w(Spam Fish Cheese Groats Bouillabase).each do |title|
        FactoryGirl.create(:tile_tag, title: title)
      end

      %w(Nope None Nil).each do |title|
        tag = FactoryGirl.create(:tile_tag, title: title)
        tile = FactoryGirl.create(:tile)
        tile.tile_tags << tag
      end

      %w(Nein Non Nyet).each do |title|
        tag = FactoryGirl.create(:tile_tag, title: title)
        draft_tile = FactoryGirl.create(:tile, status: Tile::DRAFT, is_public: true)
        archive_tile = FactoryGirl.create(:tile, status: Tile::ARCHIVE, is_public: true)
        draft_tile.tile_tags << tag
        archive_tile.tile_tags << tag
      end

      tag = FactoryGirl.create(:tile_tag, title: "ThisYes")
      tile = FactoryGirl.create(:tile, :public)
      tile.tile_tags << tag

      visit explore_path(as: a_client_admin)
      %w(Spam Fish Cheese Groats Bouillabase).each {|title| expect_no_content title}
      %w(Nope None Nil Nein Non Nyet).each {|title| expect_no_content title}
    end

    context "when a tag is clicked" do
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
        visit explore_path(as: a_client_admin)
        click_link "Click me"
        @tagged_tiles.each {|tagged_tile| expect_content tagged_tile.headline}
        @other_tagged_tiles.each {|other_tagged_tile| expect_no_content other_tagged_tile.headline}
        @untagged_tiles.each {|untagged_tile| expect_no_content untagged_tile.headline}
      end

      it "respects the tag when See More is clicked", js: true do
        # This, plus the two above, makes 13 tiles total.
        11.times do
          tile = FactoryGirl.create(:tile, :public)
          tile.tile_tags << @tag_to_click
          @tagged_tiles << tile
        end

        visit explore_path(as: a_client_admin)
        click_link "Click me"
        
        expect_thumbnail_count 8
        expect_only_headlines_in(@tagged_tiles)

        show_more_tiles_link.click
        expect_thumbnail_count 12
        expect_only_headlines_in(@tagged_tiles)

        show_more_tiles_link.click
        expect_thumbnail_count 13
        expect_only_headlines_in(@tagged_tiles)
      end

      it "allows de-selection by clicking the tag again" do
        visit explore_path(as: a_client_admin)
        click_link "Click me"
        click_link "Click me"

        expect_thumbnail_count 8
        expect_only_headlines_in(@tagged_tiles + @other_tagged_tiles + @untagged_tiles)
      end

      it "highlights the chosen tag" do
        visit explore_path(as: a_client_admin)
        page.all('.tag_link').each do |tag_link| 
          tag_link['class'].split.should include('disabled')
          tag_link['class'].split.should_not include('enabled')
        end
        click_link "Click me"

        expected_unselected_tags = page.all('.tag_link').select{|tag_link| tag_link.text != "Click me"}
        expected_selected_tag = page.all('.tag_link').select{|tag_link| tag_link.text == "Click me"}.first

        expected_unselected_tags.each do |expected_unselected_tag| 
          classes = expected_unselected_tag['class'].split
          classes.should include('disabled')
          classes.should_not include('enabled')
        end

        selected_classes = expected_selected_tag['class'].split
        selected_classes.should include('enabled')
        selected_classes.should_not include('disabled')

        click_link "Click me"
        page.all('.tag_link').each do |tag_link| 
          tag_link['class'].split.should include('disabled')
          tag_link['class'].split.should_not include('enabled')
        end
      end
    end
  end

  context "when clicking through a tile" do
    it "should have a Back link that links to the general explore page", js: true do
      tile = FactoryGirl.create(:tile, :public)
      visit explore_path(as: a_client_admin)
      page.first('.tile-wrapper').click

      click_link "Back to Explore"
      should_be_on explore_path
    end

    context "and there is a tag selected" do
      it "should have a Back link that links to that tag", js: true do
        tag = FactoryGirl.create(:tile_tag, title: "Hey Now")
        tile = FactoryGirl.create(:tile, :public)
        tile.tile_tags << tag

        visit explore_path(as: a_client_admin)
        click_link "Hey Now"
        page.first('.tile-wrapper').click

        click_link "Back to Hey Now"
        should_be_on explore_path
        page.first('.tag_link', text: 'Hey Now')['class'].split.should include('enabled')
      end
    end
  end
end
