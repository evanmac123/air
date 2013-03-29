require 'acceptance/acceptance_helper'

feature 'Signs up for trial' do

  def trial_name_input_selector
    ".customer-name"
  end

  def trial_email_input_selector
    ".customer-email"
  end
 
  def click_start_game_button
    page.first("input[value='Start a game']").click
  end

  def game_name_input_selector
    'name_game'
  end

  def click_interest_tile(content)
    page.all("p").detect{|p_tag| p_tag.text == content}.click
  end

  context 'with their name and email' do
    before do
      visit root_path
      page.first(trial_name_input_selector).set("Joey Bananas")
      page.first(trial_email_input_selector).set("joey@mafia.com")
      click_start_game_button

      should_be_on new_game_path
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

    context "when they click no interests" do
      it "should rebuke them gently"
    end

    context "when they try to select a fourth interest" do
      it "should rebuke them gently"
    end
  end

  context 'omitting a required piece of data' do
    it 'should give them a gentle rebuke'
  end
end
