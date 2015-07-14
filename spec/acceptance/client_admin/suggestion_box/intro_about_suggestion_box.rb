require 'acceptance/acceptance_helper'

feature 'Client admin sees intro about suggestion box' do
  include WaitForAjax
  include SuggestionBox

  let!(:admin) { FactoryGirl.create :client_admin, suggestion_box_intro_seen: false }
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
    "How the Suggestions Box works"
  end

  def modal
    page.find("#suggestion_box_help_modal")
  end

  def explain_button
    page.find(".suggestion_box_intro .intojs-explainbutton")
  end

  def prompt_text
    "Need ideas? Invite people to submit Tiles."
  end

  def prompt_close_icon
    page.find(".ideas_prompt .fa-close")
  end

  def access_modal_header
    "Add people to suggestion box"
  end

  before do
    visit client_admin_tiles_path
  end

  it "should show intro", js: true do
    expect_content intro_text
    expect_no_content prompt_text
    within intro do
      click_link "Got it"
    end
    expect_no_content intro_text
    expect_content prompt_text
  end

  it "should show help modal from intro", js: true do
    expect_content intro_text
    expect_no_content prompt_text

    explain_button.click
    expect_content modal_header
    expect_content prompt_text

    within modal do
      click_link "Close"
    end
    expect_content prompt_text
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
end
