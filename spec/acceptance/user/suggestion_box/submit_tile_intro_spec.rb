require 'acceptance/acceptance_helper'

feature 'Sees submit tile intro' do
  let!(:user) do 
    user = FactoryGirl.create :user, 
            allowed_to_make_tile_suggestions: true, 
            submit_tile_intro_seen: false
    user.board_memberships.first.update_attribute :allowed_to_make_tile_suggestions, true
    user
  end

  def submit_tile_btn
    page.find("#submit_tile")
  end

  def intro_text
    "Add a Tile to the Suggestion Box. If it's accepted, it will be featured on this Board."
  end

  def modal_header
    "Submit a Tile to Suggestions Box"
  end

  def explain_button
    page.find(".intojs-explainbutton")
  end

  def info_icon
    page.find("#info_submit_tile")
  end

  context "on activity page" do
    before do
      visit activity_path(as: user)
    end

    it "should show 'submit tile' button" do
      submit_tile_btn.should be_present
      submit_tile_btn.click
      current_path.should == suggested_tiles_path
    end

    it "should show intro", js: true do
      expect_content intro_text
      user.reload.submit_tile_intro_seen.should be_true
      click_link "Got it"
      expect_no_content intro_text
    end

    it "should show modal", js: true do
      expect_content "How It Works"
      explain_button.click
      expect_content modal_header
      page.find(".submit").click 
      current_path.should == suggested_tiles_path
    end
  end

  context "on suggested_tiles page" do
    before do
      visit suggested_tiles_path(as: user)
    end

    it "should show modal", js: true do
      info_icon.click
      expect_content modal_header
    end
  end
end
