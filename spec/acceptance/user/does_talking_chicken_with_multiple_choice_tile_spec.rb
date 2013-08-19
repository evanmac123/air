require 'acceptance/acceptance_helper'

feature 'Does talking chicken with multiple choice tile' do
  scenario 'works as it should', js: :webkit do
    demo = FactoryGirl.create(:demo, tutorial_type: 'multiple_choice')
    user = FactoryGirl.create(:user, demo: demo)

    visit activity_path(as: user)
    click_link 'Enter Site'
    page.find('#fancybox-content .show_tutorial').click
    page.find('#tile-thumbnail-0').click # Tile 0 is the sample tile

    expect_no_content "enter the key word here for points"
    expect_content "Earn points by reading the content and answering the question below." 
    expect_content "To answer the question, simply click on the correct answer." 

    click_link "I learned how tiles work."

    # In principle, I am against doing this to make tests work.
    # In practice, fuck it, I've spent way too long on this already.
    sleep 5
    expect_content "3. Dialogue Box"
  end
end
