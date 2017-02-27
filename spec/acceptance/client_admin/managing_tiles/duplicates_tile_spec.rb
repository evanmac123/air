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
      within find(:tile, original_tile) do
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

    it "should show success modal", js: true do
      within ".sweet-alert" do
        expect_content "Tile Copied to Drafts"
      end
    end

  end

  context "from preview" do
    before do
      find(:tile, original_tile).click
      within "#tile_preview_modal" do
        click_link "Copy"
      end
    end

    it "should add tile to draft section", js: true do
      expect(section_tile_headlines("#draft")).to eq(["Copy me!"])
    end

    it "should show success modal", js: true do
      within ".sweet-alert" do
        expect_content "Tile Copied to Drafts"
      end
    end
  end

  #
  # => Helpers
  #
  def more_btn
    binding.pry
    show_thumbnail_buttons = "$('.tile_buttons').css('opacity', '1')"
    page.execute_script show_thumbnail_buttons
    find(".more.pill")
  end
end
