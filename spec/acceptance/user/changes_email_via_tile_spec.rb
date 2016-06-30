require 'acceptance/acceptance_helper'

feature "Changes email via tile", js: true do
  let(:demo) {FactoryGirl.create :demo}
  let!(:next_tile){FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE, demo: demo, headline: "next tile")}
  let!(:tile) do
    FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE, demo: demo, question_type: Tile::SURVEY, question_subtype: Tile::CHANGE_EMAIL, question: "Do you want to change your email address for digest?", multiple_choice_answers: ["Change my email", "Keep my current email"], correct_answer_index: 0, headline: "email tile")
  end
  let(:user) {FactoryGirl.create :user, demo: demo, email: "old@email.com"}

  scenario "user should complete form for changing email" do
    visit tiles_path(as: user)
    # right tile
    expect( page.find(".tile_headline").text ).to eql(tile.headline)

    page.find(".right_multiple_choice_answer.change_email_answer").click
    within(".change_email_form") do
      expect_content "New Email Adress"
      fill_in "change_email_email", with: "new@email.com"
      click_button "Send"
    end
    expect_content "Confirmation email was sent to your current address. Please, confirm your change!"
    expect_content next_tile.headline
  end
end
