require 'acceptance/acceptance_helper'

feature 'Sees tiles on explore page' do
  it "should show only tiles that are public and active" do
    FactoryGirl.create_list(:tile, 2, :public)
    FactoryGirl.create(:tile, headline: "I do not appear in public")
    FactoryGirl.create(:tile, is_public: true, status: Tile::ARCHIVE, headline: "Nor do I appear in public")

    visit explore_path
    expect_thumbnail_count 2
    page.should_not have_content "I do not appear in public"
  end

  it "should have a working \"Show More\" button", js: true do
    FactoryGirl.create_list(:tile, 15, :public)
    visit explore_path
    expect_thumbnail_count 8

    show_more_tiles_link.click
    sleep 5
    expect_thumbnail_count 12

    show_more_tiles_link.click
    sleep 5
    expect_thumbnail_count 15
  end
end
