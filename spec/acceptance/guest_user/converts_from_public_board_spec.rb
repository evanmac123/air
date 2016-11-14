require 'acceptance/acceptance_helper'
#NOTE This spec is no longer valid since the new onboarding doesn't require
#these steps
#TODO remove this conversion spec

feature 'Guest user converts from public board', js: true do
  it "creates a user and redirects them to activity_path" do
    board = FactoryGirl.create(:demo, public_slug: "sluggg", is_public: true)
    visit public_board_path(public_slug: board.public_slug)

    click_link("Save Progress")

    page.fill_in "user[name]", with: "Airbo Name"
    page.fill_in "user[email]", with: "user1@email.com"
    page.fill_in "user[password]", with: "password"

    page.find("#guest_user_conversion_button").click

    expect(current_path).to eq(activity_path)
    expect(User.count).to eq(1)
  end
end


  # pending "buttons to open the form again or sign in" do
  #   before do
  #     visit public_board_path(public_slug: board.public_slug)
  #     wait_for_conversion_form
  #   end
  #
  #   it "should show them before you close the conversion form", js: true do
  #     expect_save_progress_button
  #     expect_sign_in_button
  #   end
  #
  #   it "should show them after you open the conversion form", js: true do
  #     close_conversion_form
  #     expect_save_progress_button
  #     expect_sign_in_button
  #
  #     visit activity_path
  #     expect_save_progress_button
  #     expect_sign_in_button
  #
  #     visit tiles_path
  #     expect_save_progress_button
  #     expect_sign_in_button
  #   end
  #
  #   it "opens the conversion form when you click the button for that", js: true do
  #     close_conversion_form
  #     click_save_progress_button
  #     expect_conversion_form
  #   end
  #
  #   it "should send you to the signin page when you click the button for that", js: true do
  #     close_conversion_form
  #     click_sign_in_button
  #     should_be_on new_session_path
  #   end
  # end
  #
  # pending "close button in conversion form" do
  #   before do
  #     visit public_board_path(public_slug: board.public_slug)
  #     wait_for_conversion_form
  #   end
  #
  #   it "should do what you would think", js: true do
  #     click_close_conversion_button
  #     expect_no_conversion_form
  #   end
  # end
  #
  # shared_examples "a successful conversion" do
  #   it "should leave the user logged in as their new real user", js: true do
  #     @setup.call
  #     local_setup
  #     # Believe it or not, this is the only place on the page I could find
  #     # the user's name.
  #     page.find("#me_toggle img")['alt'].should == "Jimmy Jones"
  #   end
  #
  #   it "should have set the password properly", js: true do
  #     @setup.call
  #     local_setup
  #     delete "/sign_out"
  #     visit sign_in_path
  #     fill_in "session[email]", with: "jim@jones.com"
  #     fill_in "session[password]", with: "jimbim"
  #     click_button "Log In"
  #
  #     should_be_on activity_path(format: 'html')
  #   end
  #
  #   it "should leave them in the proper board", js: true do
  #     @setup.call
  #     local_setup
  #     User.count.should == 1
  #
  #     new_user = User.first
  #     User.first.demo_id.should == @board.id
  #   end
  #
  #   it "should not show the sample tile lightbox", js: true do
  #     @setup.call
  #     local_setup
  #     expect_no_content site_tutorial_content
  #   end
  #
  #   it "should say something nice in the flash", js: true do
  #     @setup.call
  #     local_setup
  #     expect_welcome_flash('jim@jones.com')
  #   end
  #
  #   it "should send a confirmation email with a link that can destroy the newly-created user", js: true do
  #     @setup.call
  #     local_setup
  #     crank_dj_clear
  #
  #     user = User.last
  #     open_email(user.email)
  #
  #     visit_in_email "cancel"
  #     User.all.count.should_not be_zero
  #     expect_content user.name
  #     expect_content user.email
  #
  #     click_button "Permanently cancel my account"
  #     User.all.count.should be_zero
  #     expect_content "OK, you've cancelled that account."
  #   end
  #
  #   pending "when the email is used but unclaimed" do
  #     before do
  #       @setup.call
  #       wait_for_conversion_form
  #
  #       FactoryGirl.create(:user, email: 'jimmy@example.com')
  #       wait_for_conversion_form
  #       fill_in_conversion_name "Jimmy Jones"
  #       fill_in_conversion_email 'jimmy@example.com'
  #       fill_in_conversion_password "jimbim"
  #       submit_conversion_form
  #     end
  #
  #     it "should mark the user account as claimed", js: true do
  #       User.count.should == 1 # the one we created above, remember?
  #       User.first.claimed?.should == true
  #     end
  #   end
  # end
  #
  # shared_examples "conversion happy path without location" do
  #   # All this @setup and local_setup bullshit is because RSpec doesn't do the
  #   # right thing (i.e. what I expected) when you have before blocks split
  #   # between shared example groups and regular example groups.
  #   #
  #   # By the time you read this, there may well be a better way to do it.
  #
  #   def local_setup
  #     wait_for_conversion_form
  #     fill_in_conversion_name "Jimmy Jones"
  #     fill_in_conversion_email "jim@jones.com"
  #     fill_in_conversion_password "jimbim"
  #     submit_conversion_form
  #   end
  #
  #   it_should_behave_like "a successful conversion"
  # end
  #
  # shared_examples "conversion happy path with location" do
  #   def setup_before_visit
  #     @board = board
  #     @board.update_attributes(use_location_in_conversion: true)
  #
  #     @location_names = ["Helsinki", "Detroit Rock City", "Capital City"]
  #     @location_names.each do |location_name|
  #       FactoryGirl.create(:location, name: location_name, demo: @board)
  #     end
  #
  #     @unexpected_location_name = "St. Elsewhere"
  #     FactoryGirl.create(:location, name: @unexpected_location_name)
  #   end
  #
  #   def local_setup
  #     setup_before_visit
  #     visit public_board_path(public_slug: board.public_slug)
  #     click_link "Sign Up"
  #     wait_for_conversion_form
  #
  #     fill_in_conversion_name "Jimmy Jones"
  #     fill_in_conversion_email "jim@jones.com"
  #     fill_in_conversion_password "jimbim"
  #     submit_conversion_form
  #   end
  #
  #   it_should_behave_like "a successful conversion"
  #
  #   pending "when a location is chosen" do
  #     def local_setup
  #       setup_before_visit
  #       visit public_board_path(public_slug: board.public_slug)
  #       click_link "Sign Up"
  #       wait_for_conversion_form
  #
  #       fill_in_conversion_name "Jimmy Jones"
  #       fill_in_conversion_email "jim@jones.com"
  #       fill_in_conversion_password "jimbim"
  #       fill_in_location_autocomplete "City"
  #       expect_content "Detroit Rock City"
  #       # click_link "Detroit Rock City" doesn't work. Your guess is as good
  #       # as mine. lolcomputers.
  #       page.first('#location_autocomplete_target a').click
  #       submit_conversion_form
  #     end
  #
  #     it "should pop the proper results when a location search string is filled in", js: true do
  #       setup_before_visit
  #       visit public_board_path(public_slug: board.public_slug)
  #       wait_for_conversion_form
  #
  #       fill_in_location_autocomplete "City"
  #       page.should have_content("Detroit Rock City")
  #       page.should have_content("Capital City")
  #     end
  #
  #     it "should use the selected location", js: true do
  #       setup_before_visit
  #       visit public_board_path(public_slug: board.public_slug)
  #       wait_for_conversion_form
  #
  #       fill_in_conversion_name "Jimmy Jones"
  #       fill_in_conversion_email "jim@jones.com"
  #       fill_in_conversion_password "jimbim"
  #       fill_in_location_autocomplete "City"
  #       expect_content "Capital City"
  #       # click_link "Capital City" doesn't work. Your guess is as good
  #       # as mine. lolcomputers.
  #       page.first('#location_autocomplete_target a').click
  #
  #       local_setup
  #       user = User.last
  #       user.location.name.should == "Capital City"
  #     end
  #
  #     it_should_behave_like "a successful conversion"
  #   end
  # end
  #
  # shared_examples "no user creation" do
  #   it "should not create a user", js: true do
  #     User.count.should be_zero
  #   end
  # end
  #
  # shared_examples "conversion unhappy path" do
  #   before do
  #     @setup.call
  #     wait_for_conversion_form
  #   end
  #
  #   pending "when the name is missing" do
  #     before do
  #       fill_in_conversion_email "jimmy@example.com"
  #       fill_in_conversion_password "jimbim"
  #       submit_conversion_form
  #     end
  #
  #     it "should show errors", js: true do
  #       expect_name_error
  #     end
  #
  #     it_should_behave_like "no user creation"
  #   end
  #
  #   pending "when the email is missing" do
  #     before do
  #       fill_in_conversion_name "Jim Jones"
  #       fill_in_conversion_password "jimbim"
  #       submit_conversion_form
  #     end
  #
  #     it "should show errors", js: true do
  #       expect_invalid_email_error
  #     end
  #
  #     it_should_behave_like "no user creation"
  #   end
  #
  #   pending "when the email given is in the wrong format" do
  #     before do
  #       fill_in_conversion_name "Jim Jones"
  #       fill_in_conversion_email "asdasdasdasdasdasdasdasdasdasd"
  #       fill_in_conversion_password "jimbim"
  #       submit_conversion_form
  #     end
  #
  #     it "should show errors", js: true do
  #       expect_invalid_email_error
  #     end
  #
  #     it_should_behave_like "no user creation"
  #   end
  #
  #   pending "when the password is missing" do
  #     before do
  #       fill_in_conversion_name "Jim Jones"
  #       fill_in_conversion_email "jim@example.com"
  #       submit_conversion_form
  #     end
  #
  #     it "should show errors", js: true do
  #       expect_password_error
  #     end
  #
  #     it "should show the password error juuuuust one time", js: true do
  #       matchdata = page.body.match(password_error_copy)
  #       matchdata.post_match.should_not include(password_error_copy)
  #     end
  #
  #     it_should_behave_like "no user creation"
  #   end
  #
  #   pending "when the password is too short" do
  #     before do
  #       fill_in_conversion_name "Jim Jones"
  #       fill_in_conversion_email "jim@example.com"
  #       fill_in_conversion_password "abcde"
  #       submit_conversion_form
  #     end
  #
  #     it "should show errors", js: true do
  #       expect_password_error
  #     end
  #
  #     it_should_behave_like "no user creation"
  #   end
  #
  #   pending "when the email is already taken and claimed" do
  #     before do
  #       FactoryGirl.create(:user, :claimed, email: 'jimmy@example.com')
  #       wait_for_conversion_form
  #       fill_in_conversion_email 'jimmy@example.com'
  #       submit_conversion_form
  #     end
  #
  #     it "should show the email error", js: true do
  #       expect_duplicate_email_error
  #     end
  #
  #     it "should now show the other errors", js: true do
  #       expect_no_name_error
  #       expect_no_password_error
  #     end
  #
  #     it "should have a link to signin page", js: true do
  #       page.all("a[href='/sign_in']", text: 'click here').should_not be_empty
  #     end
  #
  #     it "should have a mailto link for support", js: true do
  #       page.all("a[href='mailto:support@airbo.com']", text: "support@airbo.com").should_not be_empty
  #     end
  #
  #     it "should not create another user", js: true do
  #       User.count.should == 1 # the one we created above, remember?
  #     end
  #   end
  #
  #   pending "when a bad location name is present" do
  #     before do
  #       @board = board
  #       @board.update_attributes(use_location_in_conversion: true)
  #
  #       visit public_board_path(public_slug: board.public_slug)
  #       click_link "Sign Up"
  #       wait_for_conversion_form
  #
  #       fill_in_conversion_name "Jim Jones"
  #       fill_in_conversion_email "jim@example.com"
  #       fill_in_conversion_password "abcde"
  #       fill_in_location_autocomplete "Bunksville"
  #       submit_conversion_form
  #     end
  #
  #     it "should show errors if you submit", js: true do
  #       expect_invalid_location_name_error
  #     end
  #
  #     it "should show a reasonable message in the autocomplete target", js: true do
  #       fill_in_location_autocomplete "Bunksville Mark 2"
  #       page.should have_content("Sorry, we cannot find that location. Try again.")
  #     end
  #
  #     it_should_behave_like "no user creation"
  #   end
  #
  #   it "should clear errors between submissions", js: true do
  #     fill_in_conversion_name "Jim Jones"
  #     fill_in_conversion_email "jim@example.com"
  #     submit_conversion_form
  #
  #     expect_password_error
  #
  #     fill_in_conversion_name ""
  #     fill_in_conversion_password "foobarbaz"
  #     submit_conversion_form
  #
  #     expect_no_password_error
  #     expect_name_error
  #   end
  # end
  #
  # pending "when there are no tiles" do
  #   before do
  #     @board = board
  #     @setup = lambda{ visit public_board_path(public_slug: board.public_slug) }
  #     @no_tutorial_lightbox_expected = true
  #   end
  #
  #   it "should offer right away", js: true do
  #     visit public_board_path(public_slug: board.public_slug)
  #     expect_conversion_form
  #
  #     visit activity_path
  #     expect_no_conversion_form
  #   end
  #
  #   it_should_behave_like "conversion happy path without location"
  #   it_should_behave_like "conversion happy path with location"
  #   it_should_behave_like "conversion unhappy path"
  # end
  #
  # pending "when there is one tile" do
  #   before do
  #     @board = board
  #     @setup = lambda do
  #       create_tiles(board, 1)
  #       visit public_board_path(public_slug: board.public_slug)
  #       close_tutorial_lightbox
  #       click_link Tile.first.headline
  #       click_right_answer
  #     end
  #   end
  #
  #   it "should offer after completing that tile", js: true do
  #     create_tiles(board, 1)
  #     visit public_board_path(public_slug: board.public_slug)
  #     expect_no_conversion_form
  #
  #     close_tutorial_lightbox
  #     click_link Tile.first.headline
  #     expect_no_conversion_form
  #     click_right_answer
  #     expect_conversion_form
  #
  #     visit activity_path
  #     expect_no_conversion_form
  #     visit tiles_path
  #     expect_no_conversion_form
  #   end
  #
  #   it_should_behave_like "conversion happy path without location"
  #   it_should_behave_like "conversion happy path with location"
  #   it_should_behave_like "conversion unhappy path"
  # end
  #
  # pending "when there are two tiles" do
  #   before do
  #     @board = board
  #     @setup = lambda do
  #       create_tiles(board, 2)
  #       visit public_board_path(public_slug: board.public_slug)
  #       close_tutorial_lightbox
  #       Tile.ordered_for_explore.each do |tile|
  #         visit activity_path
  #         click_link tile.headline
  #         click_right_answer
  #       end
  #     end
  #   end
  #
  #   it "should offer after completing both tiles", js: true do
  #     create_tiles(board, 2)
  #     visit public_board_path(public_slug: board.public_slug)
  #
  #     # We do #to_a here because ordered_for_explore apparently generates a
  #     # more complex ORDER BY clause than #last can deal with, and we get a
  #     # SQL syntax error.
  #     all_tiles = Tile.ordered_for_explore.to_a
  #
  #     close_tutorial_lightbox
  #     click_link all_tiles.first.headline
  #     click_right_answer
  #     expect_no_conversion_form
  #
  #     visit activity_path
  #     click_link all_tiles.last.headline
  #     click_right_answer
  #     expect_conversion_form
  #   end
  #
  #   it_should_behave_like "conversion happy path without location"
  #   it_should_behave_like "conversion happy path with location"
  #   it_should_behave_like "conversion unhappy path"
  # end
  #
  # pending "when there are more than two tiles" do
  #   before do
  #     create_tiles(board, 4)
  #   end
  #
  #   it "should offer after completing two tiles", js: true do
  #     visit public_board_path(public_slug: board.public_slug)
  #
  #     # See above for explanation of why we do to_a
  #     all_tiles = Tile.ordered_for_explore.to_a
  #
  #     close_tutorial_lightbox
  #     click_link all_tiles.first.headline
  #     click_right_answer
  #     expect_no_conversion_form
  #
  #     visit activity_path
  #     click_link all_tiles.last.headline
  #     click_right_answer
  #     expect_conversion_form
  #
  #     visit activity_path
  #     click_link all_tiles[1].headline
  #     click_right_answer
  #     expect_no_conversion_form
  #   end
  #
  #   pending "should offer again after completing all tiles", js: true do
  #     visit public_board_path(public_slug: board.public_slug)
  #
  #     all_tiles = Tile.ordered_for_explore
  #
  #     [0, 1].each do |i|
  #       visit activity_path
  #       click_link all_tiles[i].headline
  #       click_right_answer
  #     end
  #
  #     click_close_conversion_button
  #     expect_no_conversion_form
  #
  #     visit activity_path
  #     click_link all_tiles[2].headline
  #     click_right_answer
  #     expect_no_conversion_form
  #
  #     visit activity_path
  #     click_link all_tiles[3].headline
  #     click_right_answer
  #     expect_conversion_form
  #   end
  # end
  #
  # pending "returns user after conversion to last visited page" do
  #   def local_setup
  #     wait_for_conversion_form
  #     fill_in_conversion_name "Jimmy Jones"
  #     fill_in_conversion_email "jim@jones.com"
  #     fill_in_conversion_password "jimbim"
  #     submit_conversion_form
  #   end
  #
  #   it "should return user to activity page", js: true do
  #     visit public_board_path(public_slug: board.public_slug)
  #     expect_conversion_form
  #     local_setup
  #     current_path.should == activity_path
  #   end
  #
  #   it "should return user to last tile", js: true do
  #     create_tiles(board, 2)
  #     visit public_board_path(public_slug: board.public_slug)
  #
  #     all_tiles = Tile.ordered_for_explore.to_a
  #
  #     close_tutorial_lightbox
  #     click_link all_tiles.first.headline
  #     click_right_answer
  #
  #     page.find("[data-current-tile-id='"+all_tiles[1].id.to_s+"']").should be_present
  #     click_save_progress_button
  #     expect_conversion_form
  #     local_setup
  #     current_path.should == tiles_path
  #     page.find("[data-current-tile-id='"+all_tiles[1].id.to_s+"']").should be_present
  #   end
  # end
  #
  # pending "log out" do
  #   def local_setup
  #     wait_for_conversion_form
  #     fill_in_conversion_name "Jimmy Jones"
  #     fill_in_conversion_email "jim@jones.com"
  #     fill_in_conversion_password "jimbim"
  #     submit_conversion_form
  #   end
  #
  #   after do
  #     Timecop.return
  #   end
  #
  #   it "should not log out converted user in 20 minutes after signing up", js: true do
  #     visit public_board_path(public_slug: board.public_slug)
  #     expect_conversion_form
  #     local_setup
  #     current_path.should == activity_path
  #     Timecop.travel(25.minutes)
  #
  #     visit current_path
  #     current_path.should == activity_path
  #   end
  # end
  #
  #
  #
  # def expect_no_conversion_form
  #   sleep 1 # wait for lightbox animation to finish
  #   page.all(conversion_form_selector).select(&:visible?).should be_empty
  # end
  #
  # def save_progress_button_selector
  #   "a#save_progress_button"
  # end
  #
  # def sign_in_button_selector
  #   "a#sign_in_button"
  # end
  #
  # def expect_save_progress_button
  #   page.find(save_progress_button_selector, visible: true)
  # end
  #
  # def expect_no_save_progress_button
  #   page.all(save_progress_button_selector, visible: true).should be_empty
  # end
  #
  # def click_save_progress_button
  #   page.find(save_progress_button_selector, visible: true).click
  # end
  #
  # def expect_sign_in_button
  #   page.find(sign_in_button_selector, visible: true)
  # end
  #
  # def expect_no_sign_in_button
  #   page.all(sign_in_button_selector, visible: true).should be_empty
  # end
  #
  # def click_sign_in_button
  #   page.find(sign_in_button_selector, visible: true).click
  # end
  #
  # def create_tiles(board, count)
  #   count.times {|i| FactoryGirl.create(:multiple_choice_tile, :active, headline: "Tile #{i}", demo: board)}
  # end
  #
  # def click_right_answer
  #   # This is a hack because all the animations we threw on the tile viewer
  #   # apparently confuse the shit out of poltergeist, and the claim that it
  #   # can wait for them to finish is a damned dirty lie. So we cheat and click
  #   # the hidden link that ACTUALLY triggers the Ajax request, while bypassing
  #   # animations.
  #   #page.find('.right_multiple_choice_answer').click
  #   page.find('.right_multiple_choice_answer').trigger("click")
  # end
  #
  # def click_close_conversion_button
  #   click_link "Don't Save"
  # end
  #
  # def name_error_copy
  #   "Please enter a first and last name"
  # end
  #
  # def expect_name_error
  #   expect_content name_error_copy
  # end
  #
  # def expect_no_name_error
  #   expect_no_content name_error_copy
  # end
  #
  # def expect_invalid_email_error
  #   expect_content "Whoops. Enter a valid email address"
  # end
  #
  # def expect_duplicate_email_error
  #   expect_content "It looks like that email is already taken. You can click here to sign in, or contact support@airbo.com for help."
  # end
  #
  # def expect_invalid_location_name_error
  #   expect_content "Whoops. Enter a valid location"
  # end
  #
  # def password_error_copy
  #   "Please enter a password at least 6 characters long"
  # end
  #
  # def expect_password_error
  #   expect_content password_error_copy
  # end
  #
  # def expect_no_password_error
  #   expect_no_content password_error_copy
  # end
  #
  # def expect_welcome_flash(email)
  #   #expect_content "Account created! A confirmation email will be sent to #{email}."
  # end