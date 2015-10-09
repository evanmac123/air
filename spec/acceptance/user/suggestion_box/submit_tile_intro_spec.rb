require 'acceptance/acceptance_helper'

feature 'Sees submit tile intro' do
  let!(:user) do
    user = FactoryGirl.create :user,
            allowed_to_make_tile_suggestions: true,
            submit_tile_intro_seen: false
    user.board_memberships.first.update_attribute :allowed_to_make_tile_suggestions, true
    user
  end

  let!(:admin) { FactoryGirl.create :client_admin }

  def submit_tile_btn
    page.find("#submit_tile")
  end

  def intro
    page.find(".introjs-tooltip")
  end

  def intro_text
    "Add a Tile to the Suggestion Box. If it's accepted, it will be featured on this Board."
  end

  def instruction_modal
    page.find("#submit_tile_modal")
  end

  def modal_header
    "Submit a Tile to Suggestion Box"
  end

  def explain_button
    page.find(".intojs-explainbutton")
  end

  def form
    page.find("#new_tile_builder_form")
  end

  def form_text
    "Once you submit a Tile, it cannot be edited."
  end

  context "user" do
    before do
      visit activity_path(as: user)
    end

    it "should show intro", js: true do
      expect_content intro_text
      within intro do
        click_link "Done"
      end
      expect_no_content intro_text
      # shows it only one time
      visit activity_path(as: user)
      expect_no_content intro_text
    end

    it "should show modal with instructions", js: true do
      within intro do
        expect_content intro_text
        explain_button.click
      end
      within instruction_modal do
        expect_content modal_header
        click_link "Submit Tile"
      end
      within form do
        expect_content form_text
      end
    end
  end

  context "admin" do
    it "should always show suggest button" do
      visit activity_path(as: admin)
      submit_tile_btn.should be_present
    end
  end
end
