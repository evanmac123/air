require 'acceptance/acceptance_helper'

feature 'Creates draft tile' do
  let(:user) do
    user = FactoryGirl.create :user, allowed_to_make_tile_suggestions: true
    user.board_memberships.first.update_attribute :allowed_to_make_tile_suggestions, true
    user
  end

  def submit_tile_btn
    page.find("#submit_tile")
  end

  def form
    page.find("#new_tile_builder_form")
  end

  def form_text
    "Once you submit a Tile, it cannot be edited."
  end

  def preview
    page.find(".tile_preview_container")
  end

  def preview_status_text
    "Tile submitted, waiting for acceptance"
  end

  before do
    visit activity_path(as: user)
  end

  it "should open form", js: true do
    submit_tile_btn.click
    within form do
      expect_content form_text
    end
  end

  it "should let them submit tile", js: true do
    submit_tile_btn.click
    within form do
      expect_content form_text
      fill_in_valid_form_entries
      # FIXME fill not work for sup.content
      page.execute_script("$('#tile_builder_form_supporting_content').val('Ten pounds of cheese. Yes? Or no?')")
      click_button "Submit tile"
    end
    within preview do
      expect_content preview_status_text
      expect(page).to  have_content "by Society"
      expect(page).to  have_content "Ten pounds of cheese"
      expect(page).to  have_content "Ten pounds of cheese. Yes? Or no?"
      expect(page).to  have_content "Who rules?"
      expect(page).to  have_content "http://www.google.com/foobar"
    end
  end
end
