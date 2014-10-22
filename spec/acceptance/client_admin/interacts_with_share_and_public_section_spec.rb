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

  def switch_on_explore
    share_to_explore_switcher.click
  end

  def share_to_explore_switcher
    page.find('.share_to_explore')
  end

  def copying_switcher
    if page.find('#allow_copying_off')['checked'].present?
      page.find('#allow_copying_on')
    else
      page.find('#allow_copying_off')
    end
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
      it "should open public section but not turn on share switcher", js: true do
        @tile = FactoryGirl.create(:multiple_choice_tile, demo: @client_admin.demo)
        visit client_admin_tile_path(@tile, as: @client_admin)

        expect_no_content "Share To Explore"
        page.find(".share_via_explore").click
        expect_content "Share To Explore"
        page.find('#share_on')['checked'].should_not be_present
      end
    end
  end

  context "public section" do
    before(:each) do
      @tile = FactoryGirl.create(:multiple_choice_tile, :sharable, demo: @client_admin.demo)
      visit client_admin_tile_path(@tile, as: @client_admin)
    end

    it "should not save tile public attributes without tags", js: true do
      open_public_section
      switch_on_explore
      copying_switcher.click
      page.find('#allow_copying_on')['checked'].should be_present

      wait_for_ajax
      @tile.reload.is_copyable.should be_false
    end

    scenario "tag is displayed after adding and is removable", js: true do
      open_public_section
      switch_on_explore

      add_new_tile_tag('random tag')
      find('.tile_tags > li').should have_content('random tag')

      find('.tile_tags > li > .fa-times').click
      page.should_not have_content('random tag')
     
      page.should_not have_css('.tile_tags > li')
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
      switch_on_explore
      add_new_tile_tag "tag"

      wait_for_ajax
      TileTag.last.title.should eq "tag"
      TileTag.last.tiles.first.should == @tile
      @tile.reload.is_public.should be_true
      @tile.reload.is_copyable.should be_false
    end
  end

  context "share turned on without tags" do
    shared_examples_for "if user leaves page by link" do |name, selector|
      before(:each) do
        @tile = FactoryGirl.create(:multiple_choice_tile, :sharable, demo: @client_admin.demo)
        visit client_admin_tile_path(@tile, as: @client_admin)
        open_public_section
        switch_on_explore
      end

      it "#{name} then should show error message", js: true do
        page.find(selector).click
        page.should have_content("Add a tag to continue")
      end
    end

    it_should_behave_like "if user leaves page by link", "back", "#back_header a"
    it_should_behave_like "if user leaves page by link", "archive", "#archive"
    it_should_behave_like "if user leaves page by link", "edit", ".edit_header a"
    it_should_behave_like "if user leaves page by link", "new", ".new_tile_header a"
  end
end
