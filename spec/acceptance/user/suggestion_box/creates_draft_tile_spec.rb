require 'acceptance/acceptance_helper'

feature 'Creates draft tile' do
  let(:user) do
    user = FactoryBot.create :user, allowed_to_make_tile_suggestions: true
    user.board_memberships.first.update_attribute :allowed_to_make_tile_suggestions, true
    user
  end

  before do
    visit activity_path(as: user)
  end

  it "should open form", js: true do
    submit_tile_btn.click
    expect_content "Save Tile"
  end

  # it "should let them submit tile", js: true do
  #   submit_tile_btn.click
  #   fill_in_tile_form_entries(edit_text: "baz", points: "10")
  #   page.find(".submit_tile_form").click
  #   page.find(".viewer")
  #
  #   within ".viewer" do
  #     expect(page).to  have_content "by Society"
  #     expect(page).to  have_content "Ten pounds of cheese"
  #     expect(page).to  have_content "Ten pounds of cheese. Yes? Or no?"
  #     expect(page).to  have_content "Who rules?"
  #   end
  # end

  def submit_tile_btn
    page.find("#submit_tile")
  end
end
