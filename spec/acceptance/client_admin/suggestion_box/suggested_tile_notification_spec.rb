require 'acceptance/acceptance_helper'

feature 'Client admin sees intro about suggestion box' do
  include WaitForAjax
  include SuggestionBox

  let!(:admin) { FactoryGirl.create :client_admin, suggestion_box_intro_seen: false, suggestion_box_prompt_seen: false }
  let!(:demo)  { admin.demo  }
  let!(:user) { FactoryGirl.create :user, demo: demo }
  let!(:tile) { FactoryGirl.create :tile, :user_submitted, demo: demo }

  def subject
    "New Tile Submitted Needs Review"
  end

  def intro_text
    "Accept the Tile to use it in your Board, " +
      "or Ignore it to mark it as reviewed."
  end

  def intro_sel
    page.find(".user_submitted_tile_intro")
  end

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  before do
    admin.user_submitted_tile_intro_seen = false
    admin.suggestion_box_intro_seen = true
    admin.save
    
    visit review_suggested_tiles_path demo_id: demo.id
  end

  it "should show intro", js: true do
    expect_content intro_text
    current_path.should == client_admin_tiles_path
    within intro_sel do
      click_link "Got it"
    end
    expect_no_content intro_text
  end
end
