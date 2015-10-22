require 'acceptance/acceptance_helper'

feature 'Topics on Explore' do
  def expect_only_headlines_in(tiles)
    valid_headlines = tiles.map(&:headline)
    page.all('.headline').map(&:text).each do |found_headline|
      valid_headlines.should include(found_headline)
    end
  end

  before do
    @topics = ["Benefits", "Compliance"]
    @benefits_tags = ["Health Plan Basics", "Rx Benefits", "Health Care Reform", "Health Care Consumerism", "Dental", "Vision", "Open Enrollment Process", "Decision Support"].sort
    @compliance_tags = ["Policy", "Sexual Harassment", "Compliance Form"].sort
    full_topics = {
      @topics[0] => @benefits_tags,
      @topics[1] => @compliance_tags
    }
    Topic.make_topics_with_tags full_topics
  end

  context "Explore Page" do
    it "should show topics" do
      visit explore_path(as: a_client_admin)
      within ".topics" do
        expect_content @topics.join(" ")
      end

      within ".topics" do
        click_link @topics[0]
      end
      expect_content "Explore: #{@topics[0]}"
    end
  end

  context "Topic Page" do
    before do
      @topic = Topic.where(name: @topics[0]).first
      @tags = @benefits_tags.map{|title| TileTag.where(title: title).first }
    end

    it "should show tags" do
      visit explore_topic_path(@topic, as: a_client_admin)
      within ".tags" do
        expect_content @benefits_tags.join(" ")
      end
    end

    it "truncate long tags on the explore page" do
      Topic.make_topics_with_tags({@topics[0] => ["FishCheeseGroatsBouillabasePotato"]})

      visit explore_topic_path(@topic, as: a_client_admin)
      within ".tags" do
        expect_content "FishCheeseGroatsBouillab..."
      end
    end

    it "respects the topic when See More is clicked", js: true do
      topic_tiles = []
      33.times do |i|
        tile = FactoryGirl.create(:tile, :public)
        @tags[i % 8].tiles.push tile
        topic_tiles.push tile
      end

      visit explore_topic_path(@topic, as: a_client_admin)

      expect_thumbnail_count 16, '.explore_tile'
      expect_only_headlines_in(topic_tiles)

      show_more_tiles_link.click
      expect_thumbnail_count 32, '.explore_tile'
      expect_only_headlines_in(topic_tiles)

      show_more_tiles_link.click
      expect_thumbnail_count 33, '.explore_tile'
      expect_only_headlines_in(topic_tiles)
    end
  end
end
