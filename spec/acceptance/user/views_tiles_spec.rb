require 'acceptance/acceptance_helper'

feature 'User views tile' do
  def click_next_button
    page.find('#next').click
  end

  def click_prev_button
    page.find('#prev').click
  end

  def setup_data
    @demo = FactoryGirl.create(:demo)
    @kendra = FactoryGirl.create(:user, demo: @demo, password: 'milking', session_count: 5)

    ['make toast', 'discover fire'].each do |tile_headline|
      FactoryGirl.create(:tile, headline: tile_headline, demo: @demo)
    end

    @make_toast = Tile.find_by_headline('make toast')
    @discover_fire = Tile.find_by_headline('discover fire')
    @make_toast.update_attributes(activated_at: Time.now - 60.minutes)
    @discover_fire.update_attributes(activated_at: Time.now)
  end

  context "first tile hint" do
    before(:each) do
      setup_data
      bypass_modal_overlays(@kendra)
    end

    scenario "should see first tile hint if there are completions", js:true do
      signin_as(@kendra, 'milking')
      expect(page).to have_content("Click on the Tile to begin.")
      click_link 'Got it', visible: false #TODO figure out why visible:false is required even though the link is visible visually

      expect(page).to have_no_content("Click on the Tile to begin.")
    end

    scenario "should not see first tile hint if user has completed tilese", js:true do
      UserIntro.any_instance.stubs(:displayed_first_tile_hint).returns true
      signin_as(@kendra, 'milking')
      expect(page).to have_no_content("Click on the Tile to begin.")
    end
  end

  context "when there are tiles to be seen" do
    before(:each) do
      setup_data
      bypass_modal_overlays(@kendra)
      signin_as(@kendra, 'milking')
    end

    scenario 'views tile image', js: true do
      # Click on the first tile, and it should take you to the tiles  path
      click_link 'discover fire'
      should_be_on tiles_path

      expect_current_tile_id(@discover_fire)
      click_next_button
      expect_current_tile_id(@make_toast)
    end

    context "when a tile has no attached link address" do
      before(:each) do
        @make_toast.link_address.should be_blank
      end

      scenario "it should not be wrapped in a link" do
        visit tile_path(@make_toast)
        toast_image = page.find("img[alt='make toast']")
        parent = page.find(:xpath, toast_image.path + "/..")

        parent.tag_name.should_not == "a"
        parent.click
        should_be_on tiles_path
      end
    end
  end

  context "when there are no tiles to be seen" do
    it "should show 4 placeholders" do
      user = FactoryGirl.create(:user, :claimed)
      user.demo.tiles.should be_empty

      visit activity_path(as: user)
      page.all(".placeholder_tile.tile_thumbnail").count.should == 4
    end
  end
end
