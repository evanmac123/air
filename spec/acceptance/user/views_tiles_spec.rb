require 'acceptance/acceptance_helper'

feature 'User views tile' do
  def click_next_button
    page.find('#next').click
  end

  def click_prev_button
    page.find('#prev').click
  end

  def setup_data
    @demo = FactoryBot.create(:demo)
    @kendra = FactoryBot.create(:user, demo: @demo, password: 'milking', session_count: 5)

    ['make toast', 'discover fire'].each do |tile_headline|
      FactoryBot.create(:tile, headline: tile_headline, demo: @demo)
    end

    @make_toast = Tile.find_by_headline('make toast')
    @discover_fire = Tile.find_by_headline('discover fire')
    @make_toast.update_attributes(activated_at: Time.current - 60.minutes)
    @discover_fire.update_attributes(activated_at: Time.current)
  end

  context "when there are tiles to be seen" do
    before(:each) do
      setup_data
      bypass_modal_overlays(@kendra)
      signin_as(@kendra, 'milking')
    end

    scenario 'views tile image', js: true do
      within ".js-board-welcome-modal" do
        page.find(".close-airbo-modal").click
      end
      # Click on the first tile, and it should take you to the tiles  path
      click_link 'discover fire'
      should_be_on tiles_path

      expect_current_tile_id(@discover_fire)
      click_next_button
      expect_current_tile_id(@make_toast)
    end
  end

  context "when there are no tiles to be seen" do
    it "should show 4 placeholders" do
      user = FactoryBot.create(:user, :claimed)
      expect(user.demo.tiles).to be_empty

      visit activity_path(as: user)
      expect(page.all(".placeholder_tile.tile_thumbnail").count).to eq(4)
    end
  end
end
