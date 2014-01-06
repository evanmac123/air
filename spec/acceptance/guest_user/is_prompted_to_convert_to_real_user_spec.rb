require 'acceptance/acceptance_helper'

feature 'Guest user is prompted to convert to real user' do
  let (:board) {FactoryGirl.create(:demo, public_slug: "sluggg")}

  def conversion_form_selector
    "form[action='#{guest_user_conversions_path}']"
  end

  def wait_for_conversion_form
    page.find(conversion_form_selector, visible: true)
  end

  def expect_conversion_form
    wait_for_conversion_form

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

  def save_progress_button_selector
    "a#save_progress_button"
  end

  def sign_in_button_selector
    "a#sign_in_button"
  end

  def expect_save_progress_button
    page.find(save_progress_button_selector, visible: true)
  end

  def expect_no_save_progress_button
    page.all(save_progress_button_selector, visible: true).should be_empty
  end

  def click_save_progress_button
    page.find(save_progress_button_selector, visible: true).click
  end

  def expect_sign_in_button
    page.find(sign_in_button_selector, visible: true)
  end

  def expect_no_sign_in_button
    page.all(sign_in_button_selector, visible: true).should be_empty
  end

  def click_sign_in_button
    page.find(sign_in_button_selector, visible: true).click
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

  def close_conversion_form
    evaluate_script("$('#guest_conversion_form_wrapper').trigger('close')")
    page.find('#guest_conversion_form_wrapper', visible: false)
  end

  def expect_name_error
    expect_content "Please enter a first and last name"
  end

  def expect_invalid_email_error
    expect_content "Please enter a valid email address"
  end

  def expect_duplicate_email_error
    expect_content "It looks like that email is already taken. You can click here to sign in, or contact support@hengage.com for help."
  end

  def password_error_copy
    "Please enter a password at least 6 characters long"  
  end

  def expect_password_error
    expect_content password_error_copy
  end

  def expect_no_password_error
    expect_no_content password_error_copy
  end

  context "buttons to open the form again or sign in" do
    before do
      visit public_board_path(public_slug: board.public_slug)
      wait_for_conversion_form
    end

    it "should not show them before you close the conversion form", js: true do
      expect_no_save_progress_button
      expect_no_sign_in_button
    end

    it "should show them after you open the conversion form", js: true do
      close_conversion_form
      expect_save_progress_button
      expect_sign_in_button

      visit activity_path
      expect_save_progress_button
      expect_sign_in_button

      visit tiles_path
      expect_save_progress_button
      expect_sign_in_button
    end

    it "opens the conversion form when you click the button for that", js: true do
      close_conversion_form
      click_save_progress_button
      expect_conversion_form
    end

    it "should send you to the signin page when you click the button for that", js: true do
      close_conversion_form
      click_sign_in_button
      should_be_on new_session_path
    end
  end

  shared_examples "conversion happy path" do
    # All this @setup and local_setup bullshit is because RSpec doesn't do the
    # right thing (i.e. what I expected) when you have before blocks split 
    # between shared example groups and regular example groups.
    #
    # By the time you read this, there may well be a better way to do it.

    def local_setup
      wait_for_conversion_form
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

    it "should not show the sample tile", js: true do
      @setup.call
      local_setup
      expect_no_site_tutorial_lightbox
    end

    it "should send a confirmation email with a link that can destroy the newly-created user", js: true do
      @setup.call
      local_setup
      crank_dj_clear

      user = User.last
      open_email(user.email)

      visit_in_email "click here to cancel this account"
      User.all.count.should_not be_zero
      expect_content user.name
      expect_content user.email

      click_button "Yes, I want to cancel this account."
      User.all.count.should be_zero
      expect_content "OK, you've cancelled that account."
    end
  end

  shared_examples "no user creation" do
    it "should not create a user", js: true do
      User.count.should be_zero
    end
  end

  shared_examples "conversion unhappy path" do
    before do
      @setup.call
      wait_for_conversion_form
    end

    context "when the name is missing" do
      before do
        fill_in_conversion_email "jimmy@example.com"
        fill_in_conversion_password "jimbim"
        submit_conversion_form
      end

      it "should show errors", js: true do
        expect_name_error
      end

      it_should_behave_like "no user creation"
    end

    context "when the email is missing" do
      before do
        fill_in_conversion_name "Jim Jones"
        fill_in_conversion_password "jimbim"
        submit_conversion_form
      end

      it "should show errors", js: true do
        expect_invalid_email_error
      end

      it_should_behave_like "no user creation"
    end

    context "when the email given is in the wrong format" do
      before do
        fill_in_conversion_name "Jim Jones"
        fill_in_conversion_email "asdasdasdasdasdasdasdasdasdasd"
        fill_in_conversion_password "jimbim"
        submit_conversion_form
      end

      it "should show errors", js: true do
        expect_invalid_email_error
      end

      it_should_behave_like "no user creation"
    end

    context "when the password is missing" do
      before do
        fill_in_conversion_name "Jim Jones"
        fill_in_conversion_email "jim@example.com"
        submit_conversion_form
      end

      it "should show errors", js: true do
        expect_password_error
      end

      it "should show the password error juuuuust one time", js: true do
        matchdata = page.body.match(password_error_copy)
        matchdata.post_match.should_not include(password_error_copy)
      end

      it_should_behave_like "no user creation"
    end

    context "when the password is too short" do
      before do
        fill_in_conversion_name "Jim Jones"
        fill_in_conversion_email "jim@example.com"
        fill_in_conversion_password "abcde"
        submit_conversion_form
      end

      it "should show errors", js: true do
        expect_password_error
      end

      it_should_behave_like "no user creation"
    end

    context "when the email is already taken" do
      before do
        FactoryGirl.create(:user, email: 'jimmy@example.com')
        wait_for_conversion_form
        fill_in_conversion_name "Jimmy"
        fill_in_conversion_email 'jimmy@example.com'
        fill_in_conversion_password 'jimjim'
        submit_conversion_form
      end

      it "should show errors", js: true do
        expect_duplicate_email_error
      end

      it "should have a link to signin page", js: true do
        page.all("a[href='/sign_in']", text: 'click here').should_not be_empty
      end

      it "should have a mailto link for support", js: true do
        page.all("a[href='mailto:support@hengage.com']", text: "support@hengage.com").should_not be_empty
      end

      it "should not create another user", js: true do
        User.count.should == 1 # the one we created above, remember?
      end
    end

    it "should clear errors between submissions", js: true do
      fill_in_conversion_name "Jim Jones"
      fill_in_conversion_email "jim@example.com"
      submit_conversion_form

      expect_password_error

      fill_in_conversion_name ""
      fill_in_conversion_password "foobarbaz"
      submit_conversion_form

      expect_no_password_error
      expect_name_error
    end
  end

  context "when there are no tiles" do
    before do
      @board = board
      @setup = lambda{ visit public_board_path(public_slug: board.public_slug) }
    end

    it "should offer right away", js: true do
      visit public_board_path(public_slug: board.public_slug)
      expect_conversion_form

      visit activity_path
      expect_no_conversion_form
    end

    it_should_behave_like "conversion happy path"
    it_should_behave_like "conversion unhappy path"
  end

  context "when there is one tile" do
    before do
      @board = board
      @setup = lambda do
        create_tiles(board, 1) 
        visit public_board_path(public_slug: board.public_slug)
        click_link Tile.first.headline  
        click_right_answer
      end
    end

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

    it_should_behave_like "conversion happy path"    
    it_should_behave_like "conversion unhappy path"
  end

  context "when there are two tiles" do
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

    it_should_behave_like "conversion happy path"
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
end
