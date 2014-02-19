require 'acceptance/acceptance_helper'

feature 'Sees tiles on explore page' do
  it "should show only tiles that are public and active" do
    FactoryGirl.create_list(:tile, 2, :public)
    FactoryGirl.create(:tile, headline: "I do not appear in public")
    FactoryGirl.create(:tile, is_public: true, status: Tile::ARCHIVE, headline: "Nor do I appear in public")

    visit explore_path
    page.all('.tile-wrapper').should have(2).visible_tiles
    page.should_not have_content "I do not appear in public"
  end

  it "should have a working \"Show More\" button"
end
