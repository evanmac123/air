require 'acceptance/acceptance_helper'

feature 'Client admin duplicates tile' do
  let!(:demo) { FactoryGirl.create :demo }
  let!(:client_admin) { FactoryGirl.create :client_admin, demo: demo }
  let!(:original_tile) { FactoryGirl.create :multiple_choice_tile, :active, demo: demo, headline: "Copy me!" }

  shared_examples_for "duplicating a tile" do
    it "should add tile to draft section", js: true do
      expect(section_tile_headlines("#draft")).to eq(["Copy me!"])
    end

    it "should show success modal", js: true do
      within ".sweet-alert" do
        expect_content "Tile Copied to Drafts"
      end
    end
  end

  context "on Edit Page" do
    before do
      visit client_admin_tiles_path(as: client_admin)
    end

    it "should show only one tile in posted section", js: true do
      expect(section_tile_headlines("#draft")).to eq([])
      expect(section_tile_headlines("#active")).to eq(["Copy me!"])
      expect(section_tile_headlines("#archive")).to eq([])
    end

    context "From thumbnail menu" do
      before do
        within find(:tile, original_tile) do
          more_btn.click
        end
        within ".tooltipster-content .tile_thumbnail_menu" do
          click_link "Copy"
        end
      end

      it_should_behave_like "duplicating a tile"
    end

    context "Duplicate tile" do
      before do
        find(:tile, original_tile).click
        click_link "Copy"
      end

      it_should_behave_like "duplicating a tile"
    end
  end

  #
  # => Helpers
  #
  def more_btn
    show_thumbnail_buttons = "$('.tile_buttons').css('opacity', '1')"
    page.execute_script show_thumbnail_buttons
    find(".more_button")
  end
end
