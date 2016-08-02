require 'acceptance/acceptance_helper'

feature 'Sees tiles on explore page' do
  it "should show only tiles that are public and active or archived" do
    FactoryGirl.create_list(:tile, 2, :public)
    FactoryGirl.create(:tile, headline: "I do not appear in public")
    FactoryGirl.create(:tile, :public, status: Tile::ARCHIVE)

    visit explore_path(as: a_client_admin)
    expect_thumbnail_count 3
    page.should_not have_content "I do not appear in public"
  end

  xit "should have a working \"Show More\" button", js: true do
   #FIXME move to teaspoon etc.

    FactoryGirl.create_list(:tile, 47, :public)
    visit explore_path(as: a_client_admin)
    expect_thumbnail_count 16

    # These "sleep"s are a terrible hack, but I haven't gotten any of the
    # saner ways to get Poltergeist to wait for the AJAX request to work yet.
    show_more_tiles_link.click
    #sleep 5
    expect_thumbnail_count 32

    show_more_tiles_link.click
    #sleep 5
    expect_thumbnail_count 47
  end


  context "when clicking the \"Explore\" link to go back to the main explore page from a topic page" do
    it "should pass controller 'return_to_explore_source: Explore Topic Page - Back To Explore param" do
      tile_tag = FactoryGirl.create(:tile_tag)
      visit tile_tag_show_explore_path(tile_tag: tile_tag.id, as: a_client_admin)

      expect(find_link('Explore:')[:href]).to eq("/client_admin/explore?return_to_explore_source=Explore+Topic+Page+-+Back+To+Explore")
    end
  end
end
