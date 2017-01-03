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
    expect(page).to have_css('.share_to_explore')
    expect(page).to have_no_css('.share_to_explore.disabled')
  end

  before do
    skip
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
      expect(page.find('#sharable_tile_link_off')['checked']).to be_present
    end

    it "should sharable link should be disabled", js: true do
      expect(page.find('#sharable_tile_link')['disabled']).to be_present
    end

    it "should change is_sharable attr and sharable link", js: true do
      sharable_link_switcher.click

      expect(page.find('#sharable_tile_link')['disabled']).not_to be_present
      wait_for_ajax
      expect(@tile.reload.is_sharable).to be_truthy

      sharable_link_switcher.click

      expect(page.find('#sharable_tile_link')['disabled']).to be_present
      wait_for_ajax
      expect(@tile.reload.is_sharable).to be_falsey
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
        expect(page.find('#sharable_tile_link_on')['checked']).to be_present
        expect(page.find('#sharable_tile_link')['disabled']).not_to be_present
        wait_for_ajax
        expect(@tile.reload.is_sharable).to be_truthy
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
        expect(page).to have_no_css('.share_to_explore', visible: true)
        open_public_section
        expect(page).to have_css('.share_to_explore', visible: true)
        expect(page.find('#share_on')['checked']).not_to be_present
      end

      context "when there are no tags" do
        it "should start in a disabled state and enable when a tag is entered", js: true do
          visit client_admin_tile_path(@tile, as: @client_admin)
          open_public_section
          expect(page).to have_css('.share_to_explore.disabled')

          add_new_tile_tag('The Humpty Dance')
          expect(page).to have_css('.share_to_explore')
          expect(page).to have_no_css('.share_to_explore.disabled')
        end
      end

      context "when there are tags" do
        before do
          FactoryGirl.create(:tile_tagging, tile: @tile)
          @tile.update_attributes(is_public: true)
          visit client_admin_tile_path(@tile, as: @client_admin)
        end

        it "should start in an enabled state and be disabled if all tags are removed", js: true do
          expect(page).to have_css('.share_to_explore')
          expect(page).to have_no_css('.share_to_explore.disabled')

          find('#share_off').trigger('click') # got to switch off sharing before you can remove the tag
          find('.tile_tags > li:first > .fa-times').click()
          expect(page).to have_css('.share_to_explore.disabled')
        end

        it "should not allow the last tag to be removed if sharing is on", js: true do
          find('.tile_tags > li:first > .fa-times').click()
          expect(page).to have_css('.tile_tags li')
          expect(page).to have_css('.tag_alert', visible: true)
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

          expect(page).to have_no_css('.share_to_explore.remove_from_explore')
          expect(page).to have_css('.share_to_explore', text: "Share To Explore")
        end
      end

      context "when the tile starts non-public" do
        before do
          expect(@tile.is_public).to be_falsey
        end

        it "should switch when toggled", js: true do
          visit client_admin_tile_path(@tile, as: @client_admin)
          open_public_section
          add_new_tile_tag('The Humpty Dance')

          expect(page).to have_css('.share_to_explore', visible: true)
          expect(page).to have_no_css('.share_to_explore.disabled')

          page.find('.share_to_explore').trigger('click')

          expect(page).to have_css('.share_to_explore.remove_from_explore', text: 'Remove From Explore')
        end
      end
    end
  end

  context "public section" do
    before(:each) do
      @tile = FactoryGirl.create(:multiple_choice_tile, :sharable, demo: @client_admin.demo)
      visit client_admin_tile_path(@tile, as: @client_admin)
    end

    scenario "tag is displayed after adding and is removable", js: true do
      open_public_section

      add_new_tile_tag('random tag')
      expect(find('.tile_tags > li')).to have_content('random tag')

      find('.tile_tags > li > .fa-times').click
      expect(page).not_to have_content('random tag')

      expect(page).not_to have_css('.tile_tags > li')
    end

    scenario "displays similiar tags and add tag button if exactly same tag is not present", js: true do
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

    scenario "tile public attrs are saved correctly if tags are added", js: true do
      open_public_section
      add_new_tile_tag "tag"
      wait_for_explore_to_activate
      # I SWEAR this works in a real browser, good luck trying to click the
      # share_to_explore div that actually SHOULD make this happen so we don't
      # have to cheat.
      page.find('.share_to_explore').trigger('click')

      wait_for_ajax

      expect(TileTag.last.title).to eq "tag"
      expect(TileTag.last.tiles.first).to eq(@tile)
      expect(@tile.reload.is_public).to be_truthy
    end

    context "position on explore page" do
      before(:each) do
        @explore_tiles = []
        4.times do |i|
          @explore_tiles.push FactoryGirl.create :multiple_choice_tile, :public, explore_page_priority: i
        end
        visit client_admin_tile_path(@tile, as: @client_admin)
      end

      scenario "should set max explore_page_priority for tile", js: true do
        expect(@tile.reload.explore_page_priority).to be_nil

        open_public_section
        add_new_tile_tag "tag"
        wait_for_explore_to_activate
        page.find('.share_to_explore').trigger('click')

        expect_content "Success--thanks for sharing!"
        wait_for_ajax

        expect(@tile.reload.explore_page_priority).to eq(4)
      end

      scenario "should set tile to the first position on explore page", js: true do
        open_public_section
        add_new_tile_tag "tag"
        wait_for_explore_to_activate
        page.find('.share_to_explore').trigger('click')

        wait_for_ajax

        visit explore_path
        tiles_on_page = page.all(".headline .text").map(&:text)
        expected_tiles = [@tile.headline] + @explore_tiles.reverse.map(&:headline)
        expect(tiles_on_page).to eq(expected_tiles)
      end
    end
  end
end
