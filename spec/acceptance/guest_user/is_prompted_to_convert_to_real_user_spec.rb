require 'acceptance/acceptance_helper'

feature 'Guest user is prompted to convert to real user' do
  let (:board) {FactoryGirl.create(:demo, public_slug: "sluggg")}

  def conversion_form_selector
    "form[action='#{guest_user_conversions_path}']"
  end

  def expect_conversion_form
    page.find(conversion_form_selector, visible: true)

    within(conversion_form_selector) do
      page.find("input[type=text][name='user[name]']").should be_present
      page.find("input[type=text][name='user[email]']").should be_present
      page.find("input[type=password][name='user[password]']").should be_present
    end
  end

  def expect_no_conversion_form
    sleep 1 # wait for lightbox animation to finish
    page.all(conversion_form_selector).select(&:visible?).should be_empty
  end

  def create_tiles(board, count)
    count.times {|i| FactoryGirl.create(:multiple_choice_tile, :active, headline: "Tile #{i}", demo: board)}
  end

  def click_right_answer
    page.find('.right_multiple_choice_answer').click
  end

  def fill_in_conversion_name(name)
    within(conversion_form_selector) do
      page.find("[name='user[name]']").set(name)
    end
  end

  def fill_in_conversion_email(email)
    within(conversion_form_selector) do
      page.find("[name='user[email]']").set(email)
    end
  end

  def fill_in_conversion_password(password)
    within(conversion_form_selector) do
      page.find("[name='user[password]']").set(password)
    end
  end

  def submit_conversion_form
    within(conversion_form_selector) do
      page.find("input[type=submit]").click
    end
  end

  shared_examples "conversion happy path" do
    # All this @setup and local_setup bullshit is because RSpec doesn't do the
    # right thing (i.e. what I expected) when you have before blocks split 
    # between shared example groups and regular example groups.
    #
    # By the time you read this, there may well be a better way to do it.

    def local_setup
      sleep 1
      fill_in_conversion_name "Jimmy Jones"
      fill_in_conversion_email "jim@jones.com"
      fill_in_conversion_password "jimbim"
      submit_conversion_form
    end

    it "should leave the user logged in as their new real user", js: true do
      @setup.call
      local_setup
      # Believe it or not, this is the only place on the page I could find
      # the user's name.
      page.find("#me_toggle img")['alt'].should == "Jimmy Jones"
    end

    it "should have set the password properly", js: true do
      @setup.call
      local_setup
      delete "/sign_out"
      visit sign_in_path
      fill_in "session[email]", with: "jim@jones.com"
      fill_in "session[password]", with: "jimbim"
      click_button "Log In"

      should_be_on activity_path(format: 'html')
    end

    it "should leave them in the proper board", js: true do
      @setup.call
      local_setup
      User.count.should == 1

      new_user = User.first
      User.first.demo_id.should == @board.id
    end

    it "should not show the sample tile"
  end

  shared_examples "conversion unhappy path" do
    it "should show errors if name is left out"
    it "should show errors if email is left out"
    it "should show errors if password is left out"
    it "should show errors if email is already taken"
  end

  context "when there are no tiles" do
    it "should offer right away", js: true do
      visit public_board_path(public_slug: board.public_slug)
      expect_conversion_form

      visit activity_path
      expect_no_conversion_form
    end

    it_should_behave_like "conversion happy path" do
      before do
        @board = board
        @setup = lambda{ visit public_board_path(public_slug: board.public_slug) }
      end
    end

    it_should_behave_like "conversion unhappy path"
  end

  context "when there is one tile" do
    it "should offer after completing that tile", js: true do
      create_tiles(board, 1)
      visit public_board_path(public_slug: board.public_slug)
      expect_no_conversion_form

      click_link Tile.first.headline
      expect_no_conversion_form
      click_right_answer
      expect_conversion_form

      visit activity_path
      expect_no_conversion_form
      visit tiles_path
      expect_no_conversion_form
    end

    it_should_behave_like "conversion happy path" do
      before do
        @board = board
        @setup = lambda do
          create_tiles(board, 1) 
          visit public_board_path(public_slug: board.public_slug)
          click_link Tile.first.headline  
          click_right_answer
        end
      end
    end

    it_should_behave_like "conversion unhappy path"
  end

  context "when there are two tiles" do
    it "should offer after completing both tiles", js: true do
      create_tiles(board, 2) 
      visit public_board_path(public_slug: board.public_slug)

      all_tiles = Tile.all
      
      click_link all_tiles.first.headline
      click_right_answer
      expect_no_conversion_form

      visit activity_path
      click_link all_tiles.last.headline
      click_right_answer
      expect_conversion_form
    end

    it_should_behave_like "conversion happy path" do
      before do
        @board = board
        @setup = lambda do
          create_tiles(board, 2) 
          visit public_board_path(public_slug: board.public_slug)
          Tile.all.each do |tile|
            visit activity_path
            click_link tile.headline  
            click_right_answer
          end
        end
      end
    end

    it_should_behave_like "conversion unhappy path"
  end

  context "when there are more than two tiles" do
    before do
      create_tiles(board, 4) 
    end

    it "should offer after completing two tiles", js: true do
      visit public_board_path(public_slug: board.public_slug)

      all_tiles = Tile.all
      
      click_link all_tiles.first.headline
      click_right_answer
      expect_no_conversion_form

      visit activity_path
      click_link all_tiles.last.headline
      click_right_answer
      expect_conversion_form

      visit activity_path
      click_link all_tiles[1].headline
      click_right_answer
      expect_no_conversion_form
    end

    it "should offer again after completing all tiles", js: true do
      visit public_board_path(public_slug: board.public_slug)

      all_tiles = Tile.all

      0.upto(2) do |i|
        visit activity_path
        click_link all_tiles[i].headline
        click_right_answer
      end

      expect_no_conversion_form

      visit activity_path
      click_link all_tiles.last.headline
      click_right_answer
      expect_conversion_form
    end
  end

  context "on declining the offer to convert" do
    it "should make a button appear that you can use to open the form again"
  end
end
