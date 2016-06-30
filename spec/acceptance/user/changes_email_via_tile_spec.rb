require 'acceptance/acceptance_helper'

feature "Changes email via tile", js: true do
  let(:demo) {FactoryGirl.create :demo}
  let!(:next_tile){FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE, demo: demo, headline: "next tile")}
  let!(:tile) do
    FactoryGirl.create(:multiple_choice_tile, status: Tile::ACTIVE, demo: demo, question_type: Tile::SURVEY, question_subtype: Tile::CHANGE_EMAIL, question: "Do you want to change your email address for digest?", multiple_choice_answers: ["Change my email", "Keep my current email"], correct_answer_index: 0, headline: "email tile")
  end
  let(:user) {FactoryGirl.create :user, demo: demo, email: "old@email.com"}

  it "should complete form for changing email" do
    visit tiles_path(as: user)
    # screenshot_and_open_image
    expect( page.find(".tile_headline").text ).to eql(tile.headline)
  end
end
