require 'acceptance/acceptance_helper'

feature 'Does talking chicken with multiple choice tile' do
  before do
    @demo = FactoryGirl.create(:demo, tutorial_type: 'multiple_choice')
    @user = FactoryGirl.create(:user, demo: @demo)

    visit activity_path(as: @user)
    click_link 'Enter Site'
    page.find('#fancybox-content .show_tutorial').click
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

    click_link "I learned how tiles work."
    expect_no_content "That's right! Points 10"
    expect_content "That's right! Points 5"
  end
end
