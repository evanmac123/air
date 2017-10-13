require 'acceptance/acceptance_helper'

feature 'Client admin duplicates tile' do
  let!(:demo) { FactoryGirl.create :demo }
  let!(:client_admin) { FactoryGirl.create :client_admin, demo: demo }
  let!(:original_tile) { FactoryGirl.create :multiple_choice_tile, :active, demo: demo, headline: "Copy me!" }

  before do
    visit client_admin_tiles_path(as: client_admin)
  end

  it "should show only one tile in posted section", js: true do
    expect(section_tile_headlines("#draft")).to eq([])
    expect(section_tile_headlines("#active")).to eq(["Copy me!"])
    expect(section_tile_headlines("#archive")).to eq([])
  end

  context "from thumbnail menu" do
    before do
      within ".tile_thumbnail[data-tile-id='#{original_tile.id}']" do
        page.find(".tile-wrapper").hover
        page.find(".more").click
      end

      within ".tooltipster-content .tile_thumbnail_menu" do
        click_link "Copy"
      end
    end

    it "should add tile to draft section", js: true do
      expect(section_tile_headlines("#draft")).to eq(["Copy me!"])
    end
  end

  context "from preview" do
    before do
      find( ".tile_thumbnail[data-tile-id='#{original_tile.id}']").click
      within "#tile_preview_modal" do
        click_link "Copy"
      end
    end

    it "should add tile to draft section", js: true do
      expect(section_tile_headlines("#draft")).to eq(["Copy me!"])
    end
  end
end
