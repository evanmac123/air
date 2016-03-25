require 'acceptance/acceptance_helper'

feature 'Carousel on Explore Tile Preview Page' do
  include SignUpModalHelpers
  include TilePreviewHelpers

  let (:creator) {FactoryGirl.create(:client_admin, name: "Charlotte McTilecreator")}
  let(:admin) {FactoryGirl.create(:client_admin)}

  before(:each) do
    %w(Spam Fish).each do |title|
      FactoryGirl.create(:tile_tag, title: title)
    end

    @tags = TileTag.all

    0.upto(5) do |i|
      tag = i.even? ? @tags[0] : @tags[1]
      FactoryGirl.create(:multiple_choice_tile,
        :copyable, headline: "Tile#{i}", created_at: Time.now + i.day,
        tile_tags: [tag], creator: creator, demo: creator.demo)
    end

    @tiles = Tile.ordered_for_explore
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

    it "should move to next tile after clicking right answer", js: true do
      expect_content @tiles[0].headline
      page.find('.right_multiple_choice_answer').click
      expect_content @tiles[1].headline
    end
  end

  context "if user comes to tag page" do
    before(:each) do
      visit tile_tag_show_explore_path(tile_tag: @tags.last.id, as: admin)
    end

    it "should show tiles with chosen tag upwards", js: true do
      expect_content @tiles.first.headline
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

  context "interacts with tile after mooving" do
    before(:each) do
      crank_dj_clear
      visit explore_tile_preview_path(@tiles.first, as: admin)
      @tile = @tiles.first
      expect_content @tile.headline
      show_next_tile
      @tile = @tiles[1]
      expect_content @tile.headline
    end

    it "should copy tile", js: true do
      click_copy_button

      crank_dj_clear
      expect_tile_copied(@tile, admin)
    end
  end

  def show_next_tile
    page.find("#next_tile").click
  end

  def show_previous_tile
    page.find("#prev_tile").click
  end
end
