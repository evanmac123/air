require 'acceptance/acceptance_helper'

feature 'Sees tiles on explore page' do
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
end
