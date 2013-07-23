require 'acceptance/acceptance_helper'

feature 'User views tiles' do
  def expect_supporting_content(expected_content)
    expect_content expected_content
  end

  def expect_question(question)
    expect_content question
  end

  def expect_points(points)
    expect_content "#{points} pts"
  end

  def answer(index)
    page.all('.tile_multiple_choice_answer')[index]  
  end

  def expect_answer(index, text)
    within answer(index) do
      expect_content text
    end
  end

  def click_answer(index)
    within answer(index) do
      page.find('a').click
    end
  end

  def expect_wrong_answer_reaction(index)
    within answer(index) do
      expect_content "Sorry, that's not it. Try again!"
    end
  end

  def expect_no_wrong_answer_reaction(index)
    within answer(index) do
      expect_no_content "Sorry, that's not it. Try again!"
    end
  end

  def expect_right_answer_reaction
    expect_content "That's right! Points 10/20, Tix 0" 
  end

  context 'of the keyword variety' do
    scenario 'and all the extra cool stuff around them' do
      tile = FactoryGirl.create(:keyword_tile, supporting_content: "Vote Quimby", question: "Who should you vote for?")
      tile.first_rule.update_attributes(points: 10)
      user = FactoryGirl.create(:user, demo: tile.demo)
      visit tiles_path(as: user)

      expect_supporting_content "Vote Quimby"
      expect_question "Who should you vote for?"
      expect_points 10
    end
  end

  context 'of the multiple-choice variety' do
    before do
      @tile = FactoryGirl.create(:multiple_choice_tile, points: 10)
      @user = FactoryGirl.create(:user, demo: @tile.demo)
      visit tiles_path(as: @user)
    end

    scenario 'and all the stuff around them, including the answer options' do
      expect_supporting_content "This is some extra text by the tile"
      expect_question "Which of the following comes out of a bird?"
      expect_points 10
      expect_answer 0, "Ham"
      expect_answer 1, "Eggs"
      expect_answer 2, "A V8 Buick"
    end

    scenario 'and can answer by clicking the answers', js: true do
      click_answer 0
      expect_wrong_answer_reaction 0

      click_answer 2
      expect_wrong_answer_reaction 2

      click_answer 1
      expect_no_wrong_answer_reaction 1
      expect_right_answer_reaction

      visit activity_path
      expect_content "Answered a question on the \"#{@tile.headline}\" tile"
      expect_content "10 pts"
    end
  end
end
