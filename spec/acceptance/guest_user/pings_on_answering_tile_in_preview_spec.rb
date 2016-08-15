require 'acceptance/acceptance_helper'

feature "Guest user answering a tile in preview", js:true do
  before do
    #FIXME remove explore intro so this intervation is no longer necessary
    UserIntro.any_instance.stubs(:explore_intro_seen).returns(true)
   end
  it "should show success phrase for right answer", js: true do#, driver: :selenium do
    tile = FactoryGirl.create(:multiple_choice_tile, :public)

    visit explore_tile_preview_path(id: tile.id)


    click_link "Eggs"
    page.should have_content("Correct!")
  end

  it "should not show success phrase if there is only one answer", js: true do
    tile = FactoryGirl.create(:multiple_choice_tile, :public,
      multiple_choice_answers: ["Eggs"], correct_answer_index: 0)

    visit explore_tile_preview_path(id: tile.id)


    click_link "Eggs"
    page.should_not have_content("Correct!")
  end
end
