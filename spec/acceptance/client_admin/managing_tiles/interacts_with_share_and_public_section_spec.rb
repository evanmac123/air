require 'acceptance/acceptance_helper'

feature "Client Admin Interacts With Share And Public Section" do
  include WaitForAjax

  def share_section_intro_text
    "Share tile outside of your board."
  end

  def sharable_link_switcher
    if page.find('#sharable_tile_link_off')['checked'].present?
      page.find('#sharable_tile_link_on')
    else
      page.find('#sharable_tile_link_off')
    end
  end

  def copying_switcher
    if page.find('#allow_copying_off')['checked'].present?
      page.find('#allow_copying_on')
    else
      page.find('#allow_copying_off')
    end
  end

  def wait_for_explore_to_activate
    page.should have_css('.share_to_explore')
    page.should have_no_css('.share_to_explore.disabled')
  end

  before do
    @client_admin = FactoryGirl.create(:client_admin)
  end

  context "share section intro" do
    it "should show intro when user sees share section for the first time", js: true do
      @client_admin.share_section_intro_seen = false # it should be false by default but i don't
      @client_admin.save                             # want to play with intro in every test

      tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
      
      visit client_admin_tile_path(tile, as: @client_admin)
      expect_content share_section_intro_text

      visit client_admin_tile_path(tile, as: @client_admin)
      expect_no_content share_section_intro_text
    end
  end

  context "tile share link switcher" do
    before(:each) do
      @tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
      visit client_admin_tile_path(@tile, as: @client_admin)
    end

    it "should be turned off by default", js: true do
      page.find('#sharable_tile_link_off')['checked'].should be_present
    end

    it "should sharable link should be disabled", js: true do
      page.find('#sharable_tile_link')['disabled'].should be_present
    end

    it "should change is_sharable attr and sharable link", js: true do
      sharable_link_switcher.click

      page.find('#sharable_tile_link')['disabled'].should_not be_present
      wait_for_ajax
      @tile.reload.is_sharable.should be_true

      sharable_link_switcher.click

      page.find('#sharable_tile_link')['disabled'].should be_present
      wait_for_ajax
      @tile.reload.is_sharable.should be_false
    end
  end

  context "share via buttons" do
    shared_examples_for "click share via button" do |name, selector|
      before(:each) do
        @tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
        visit client_admin_tile_path(@tile, as: @client_admin)
        page.find(selector).click
      end

      scenario "#{name} turns sharable link if it is turned off", js: true do
        page.find('#sharable_tile_link_on')['checked'].should be_present
        page.find('#sharable_tile_link')['disabled'].should_not be_present
        wait_for_ajax
        @tile.reload.is_sharable.should be_true
      end

      scenario "sends share via #{name} ping", js: true do
        expect_ping "Tile Shared", {"shared_to" => name, "tile_id" => @tile.id.to_s}, @client_admin
      end
    end

    it_should_behave_like "click share via button", "Explore",  ".share_via_explore"
    it_should_behave_like "click share via button", "Facebook", ".share_via_facebook"
    it_should_behave_like "click share via button", "Twitter",  ".share_via_twitter"
    it_should_behave_like "click share via button", "Linkedin", ".share_via_linkedin"
    it_should_behave_like "click share via button", "Email",    ".share_via_email"

    context "Airbo Explore" do
      before do
        @tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
      end

      it "should open public section but not turn on share switcher", js: true do
        visit client_admin_tile_path(@tile, as: @client_admin)
        page.should have_no_css('.share_to_explore', visible: true)
        open_public_section
        page.should have_css('.share_to_explore', visible: true)
        page.find('#share_on')['checked'].should_not be_present
      end

      context "when there are no tags" do
        it "should start in a disabled state and enable when a tag is entered", js: true, driver: :webkit do
          visit client_admin_tile_path(@tile, as: @client_admin)
          open_public_section
          page.should have_css('.share_to_explore.disabled')

          add_new_tile_tag('The Humpty Dance')
          page.should have_css('.share_to_explore')
          page.should have_no_css('.share_to_explore.disabled')
        end
      end

      context "when there are tags" do
        before do
          FactoryGirl.create(:tile_tagging, tile: @tile)
          @tile.update_attributes(is_public: true)
          visit client_admin_tile_path(@tile, as: @client_admin)
        end

        it "should start in an enabled state and be disabled if all tags are removed", js: true do
          page.should have_css('.share_to_explore')
          page.should have_no_css('.share_to_explore.disabled')

          find('#share_off').trigger('click') # got to switch off sharing before you can remove the tag
          find('.tile_tags > li:first > .fa-times').click()
          page.should have_css('.share_to_explore.disabled')
        end

        it "should not allow the last tag to be removed if sharing is on", js: true do
          find('.tile_tags > li:first > .fa-times').click()
          page.should have_css('.tile_tags li')
          page.should have_css('.tag_alert', visible: true)
        end
      end

      context "when the tile starts as public" do
        before do
          FactoryGirl.create(:tile_tagging, tile: @tile)
          @tile.update_attributes(is_public: true)
        end

        it "should switch when toggled", js: true do
          visit client_admin_tile_path(@tile, as: @client_admin)
          page.find('.share_to_explore').trigger('click')

          page.should have_no_css('.share_to_explore.remove_from_explore')
          page.should have_css('.share_to_explore', text: "Share To Explore")
        end
      end

      context "when the tile starts non-public" do
        before do
          @tile.is_public.should be_false
        end

        it "should switch when toggled", js: true, driver: :webkit do
          visit client_admin_tile_path(@tile, as: @client_admin)
          open_public_section
          add_new_tile_tag('The Humpty Dance')

          page.should have_css('.share_to_explore', visible: true)
          page.should have_no_css('.share_to_explore.disabled')

          page.find('.share_to_explore').trigger('click')

          page.should have_css('.share_to_explore.remove_from_explore', text: 'Remove From Explore')
        end
      end
    end
  end

  context "public section" do
    before(:each) do
      @tile = FactoryGirl.create(:multiple_choice_tile, :sharable, demo: @client_admin.demo)
      visit client_admin_tile_path(@tile, as: @client_admin)
    end

    scenario "tag is displayed after adding and is removable", js: true, driver: :webkit do
      open_public_section

      add_new_tile_tag('random tag')
      find('.tile_tags > li').should have_content('random tag')

      find('.tile_tags > li > .fa-times').click
      page.should_not have_content('random tag')
     
      page.should_not have_css('.tile_tags > li')
    end

    scenario "displays similiar tags and add tag button if exactly same tag is not present", js: true, driver: :webkit do
      tag1 = FactoryGirl.create :tile_tag, title: "untag"
      tag2 = FactoryGirl.create :tile_tag, title: "tagged"

      open_public_section
      write_new_tile_tag "tag"

      expect_content "untag"
      expect_content "tagged"
      expect_content "Click to add."

      write_new_tile_tag "untag"
      expect_content "untag"
    end

    scenario "tile public attrs are saved correctly if tags are added", js: true, driver: :webkit do
      open_public_section
      add_new_tile_tag "tag"
      wait_for_explore_to_activate
      # I SWEAR this works in a real browser, good luck trying to click the
      # share_to_explore div that actually SHOULD make this happen so we don't
      # have to cheat.
      page.find('.share_to_explore').trigger('click')

      wait_for_ajax

      TileTag.last.title.should eq "tag"
      TileTag.last.tiles.first.should == @tile
      @tile.reload.is_public.should be_true
      @tile.reload.is_copyable.should be_true
    end

    context "position on explore page" do
      before(:each) do
        @explore_tiles = []
        4.times do |i|
          @explore_tiles.push FactoryGirl.create :multiple_choice_tile, :public, explore_page_priority: i
        end
        visit client_admin_tile_path(@tile, as: @client_admin)
      end

      scenario "should set max explore_page_priority for tile", js: true, driver: :webkit do
        @tile.reload.explore_page_priority.should be_nil

        open_public_section
        add_new_tile_tag "tag"
        wait_for_explore_to_activate
        page.find('.share_to_explore').trigger('click')

        expect_content "Success--thanks for sharing!"
        wait_for_ajax

        @tile.reload.explore_page_priority.should == 4
      end

      scenario "should set tile to the first position on explore page", js: true, driver: :webkit do
        open_public_section
        add_new_tile_tag "tag"
        wait_for_explore_to_activate
        page.find('.share_to_explore').trigger('click')

        wait_for_ajax

        visit explore_path
        tiles_on_page = page.all(".headline .text").map(&:text)
        expected_tiles = [@tile.headline] + @explore_tiles.reverse.map(&:headline)
        tiles_on_page.should == expected_tiles
      end
    end
  end
end