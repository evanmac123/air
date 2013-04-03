require 'acceptance/acceptance_helper'

feature 'Signs up for trial' do
  def trial_name_input_selector
    ".customer-name"
  end

  def trial_email_input_selector
    ".customer-email"
  end

  def start_game_button_selector
    "input[value='Start a game']"
  end

  def start_game_button
    page.first start_game_button_selector
  end

  def click_start_game_button
    start_game_button.click
  end

  def game_name_input_selector
    'name_game'
  end

  def setup_button
    page.find("input[value='Complete setup']")
  end

  def click_interest_tile(content)
    page.all("p").detect{|p_tag| p_tag.text == content}.click
  end

  def enter_name_and_email
    visit root_path
    page.first(trial_name_input_selector).set("Joey Bananas")
    page.first(trial_email_input_selector).set("joey@mafia.com")
    click_start_game_button
    should_be_on new_game_path
  end

  def expect_setup_button_disabled
    expect_disabled(setup_button)
  end

  def expect_setup_button_enabled
    expect_not_disabled(setup_button)
  end

  def find_checkbox_by_value(text)
    page.find("input[value='#{text}']")  
  end

  def expect_interest_tile_selected(text)
    find_checkbox_by_value(text).should be_checked
  end

  def expect_interest_tile_not_selected(text)
    find_checkbox_by_value(text).should_not be_checked
  end

  def expect_missing_name_or_email_error
    expect_content "Please enter your name and email address to request a trial."
  end

  context 'with their name, email and interests' do
    before do
      enter_name_and_email
      fill_in game_name_input_selector, with: "Legitimate Businessmen's Social Club"

      click_interest_tile "Wellness"
      click_interest_tile "Onboarding"

      click_button "Complete setup"
    end

    it "should leave them with something to look at", js: true do
      should_be_on page_path("waitingroom")
    end

    it "should notify Team K", js: true do
      crank_dj_clear
      open_email("team_k@hengage.com")
      current_email.reply_to.should include("joey@mafia.com")
      current_email.subject.should == "Game creation request from Joey Bananas (Legitimate Businessmen's Social Club)"
      current_email.body.should include("Wellness")
      current_email.body.should include("Onboarding")
    end
  end

  context "when they select no interests" do
    it "should keep the submit button disabled", js: true do
      enter_name_and_email
      fill_in game_name_input_selector, with: "Just some guys"
      expect_setup_button_disabled

      click_interest_tile "Wellness"
      expect_setup_button_enabled

      click_interest_tile "Onboarding"
      expect_setup_button_enabled

      click_interest_tile "Safety"
      expect_setup_button_enabled

      # and now let's switch 'em off

      click_interest_tile "Wellness"
      expect_setup_button_enabled

      click_interest_tile "Onboarding"
      expect_setup_button_enabled

      # still one selected, but now...
      click_interest_tile "Safety"
      expect_setup_button_disabled
    end
  end

  context "when they try to select a fourth interest" do
    it "should not enable that fourth one until they unselect a selected one", js: true do
      enter_name_and_email
      click_interest_tile "Wellness"
      click_interest_tile "Onboarding"
      click_interest_tile "Safety"

      click_interest_tile "Training"
      expect_interest_tile_not_selected "Training"

      click_interest_tile "Wellness"
      click_interest_tile "Training"
      expect_interest_tile_selected "Training"
    end
  end

  context 'omitting their name or email' do
    it 'should leave the start-game button disabled until they ante up', js: true do
      visit root_path
      expect_disabled(start_game_button)

      page.first(trial_name_input_selector).set("Joey Bananas")
      expect_disabled(start_game_button)
      
      page.first(trial_email_input_selector).set("joey@mafia.com")
      expect_not_disabled(start_game_button)

      page.first(trial_name_input_selector).set("")
      expect_disabled(start_game_button)

      page.first(trial_name_input_selector).set("Joey Bananas")
      page.first(trial_email_input_selector).set("")
      expect_disabled(start_game_button)
    end
  end

  context 'not filling in a company name' do
    it "should keep the submit button disabled", js: true do
      enter_name_and_email

      click_interest_tile "Wellness"
      expect_setup_button_disabled

      fill_in game_name_input_selector, with: "Legitimate Businessmen's Social Club"
      expect_setup_button_enabled

      fill_in game_name_input_selector, with: "       "
      expect_setup_button_disabled

      fill_in game_name_input_selector, with: ''
      expect_setup_button_disabled
    end
  end
end
