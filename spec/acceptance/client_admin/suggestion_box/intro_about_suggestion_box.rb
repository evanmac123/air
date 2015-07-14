require 'acceptance/acceptance_helper'

feature 'Client admin sees intro about suggestion box' do
  include WaitForAjax
  include SuggestionBox

  let!(:admin) { FactoryGirl.create :client_admin, is_site_admin: true, suggestion_box_intro_seen: false, manage_access_prompt_seen: false }
  let!(:demo)  { admin.demo  }
  let!(:tile) { FactoryGirl.create :tile, demo: demo }

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  def intro_text
    "Give the people ability to create Tiles and submit them for your review."
  end

  def intro
    page.find(".suggestion_box_intro")
  end

  def modal_header
    "How the Suggestion Box works"
  end

  def modal
    page.find("#suggestion_box_help_modal")
  end

  def explain_button
    page.find(".suggestion_box_intro .intojs-explainbutton")
  end

  def access_modal_header
    "Add people to suggestion box"
  end

  def manage_access_prompt_text
    'To enable the Suggestion Box, select users who can access it in "Manage Access".'
  end

  before do
    visit client_admin_tiles_path
  end

  it "should show intro", js: true do
    expect_content intro_text
    within intro do
      click_link "Got it"
    end
    expect_no_content intro_text
  end

  it "should show help modal from intro", js: true do
    expect_content intro_text

    explain_button.click
    expect_content modal_header

    within modal do
      click_link "Close"
    end
  end

  it "should show access modal from help modal", js: true do
    expect_content intro_text
    explain_button.click
    expect_content modal_header

    within modal do
      click_link "Pick Users"
    end
    expect_content access_modal_header
  end

  it "should show intro only one time", js: true do
    expect_content intro_text
    visit current_path
    expect_no_content intro_text
  end

  context "Manage Access Prompt" do
    before do
      within intro do
        click_link "Got it"
      end
      suggestion_box_title.click
    end

    it "should show prompt in suggestion box tab", js: true do
      expect_content manage_access_prompt_text
    end

    it "should hide prompt after user change access to SB", js: true do
      manage_access_link.click
      all_users_switcher_on.click
      save_button.click

      expect_no_content manage_access_prompt_text
    end
  end
end
