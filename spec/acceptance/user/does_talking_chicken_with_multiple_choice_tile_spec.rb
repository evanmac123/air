require 'acceptance/acceptance_helper'

feature 'Does multiple choice tile sample tile' do
  before do
    @demo = FactoryGirl.create(:demo, tutorial_type: 'multiple_choice')
    @user = FactoryGirl.create(:user, :sample_tile_not_yet_done, demo: @demo)

    visit activity_path(as: @user)
    page.find('#tile-thumbnail-0').click # Tile 0 is the sample tile
  end

  scenario 'works as it should', js: :webkit do
    expect_no_content "enter the key word here for points"
    expect_content "Earn points by reading the content and answering the question below." 
    expect_content "To answer the question, simply click on the correct answer." 

    click_link "I learned how tiles work."
    expect_content "That's right! Points 5"
  end

  scenario "only allows user to get points for the tile once", js: :webkit do
    click_link "I learned how tiles work."
    expect_content "That's right! Points 5"
    expect_content "You've completed all available tiles"
  end
end
