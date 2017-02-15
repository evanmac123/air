require 'acceptance/acceptance_helper'

feature 'Client admin duplicates tile' do
  let!(:demo) { FactoryGirl.create :demo }
  let!(:client_admin) { FactoryGirl.create :site_admin, demo: demo }
  let!(:original_tile) { FactoryGirl.create :multiple_choice_tile, :active, demo: demo, headline: "Copy me!" }

  shared_examples_for "duplicating a tile" do
    it "should show success modal", js: true do
      within ".sweet-alert" do
        expect_content "Tile Copied to Drafts"
      end
    end
  end

  before do
    skip
    FactoryGirl.create(:campaign)
    visit explore_search_path(as: client_admin, query: "*")
  end

  context "from thumbnail menu" do
    before do
      within first(:tile, original_tile) do
        more_btn.click
      end
      within ".tooltipster-content .tile_thumbnail_menu" do
        click_link "Copy"
      end
    end

    it_should_behave_like "duplicating a tile"
  end

  context "from preview" do
    before do
      first(:tile, original_tile).click
      within "#tile_preview_modal" do
        click_link "Copy"
      end
    end

    it_should_behave_like "duplicating a tile"
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
