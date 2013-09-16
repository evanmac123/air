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
    expect_no_content "Sorry, that's not it. Try again!"
  end

  def expect_right_answer_reaction
    expect_content "That's right! Points 10/20, Tix 1" 
  end

  def show_more_tiles_link
    page.find('a.show_more_tiles')
  end

  def expect_thumbnail_count(expected_count)
    page.all('.tile-wrapper').should have(expected_count).tiles
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
      @tile = FactoryGirl.create(:multiple_choice_tile, points: 30)
      @user = FactoryGirl.create(:user, demo: @tile.demo)
      visit tiles_path(as: @user)
    end

    scenario 'and all the stuff around them, including the answer options' do
      expect_supporting_content "This is some extra text by the tile"
      expect_question "Which of the following comes out of a bird?"
      expect_points 30
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
      expect_content "30 pts"
    end

    scenario "but gets no ticket emails", js: true do
      click_answer 1
      crank_dj_clear
      ActionMailer::Base.deliveries.should be_empty
    end

    scenario "when it's not the first tile navigated to", js: true do
      other_tile = FactoryGirl.create(:tile, demo: @tile.demo, headline: "The tile upon which we will start")
      visit tile_path(other_tile, as: @user)
      page.find('#next').click

      click_answer 0
      expect_wrong_answer_reaction 0

      click_answer 2
      expect_wrong_answer_reaction 2

      click_answer 1
      expect_no_wrong_answer_reaction 1
      expect_right_answer_reaction
    end
  end

  context 'loaded in batches, with a "See More" link' do
    before do
      @demo = FactoryGirl.create(:demo)
      user = FactoryGirl.create(:user, demo: @demo, sample_tile_completed: true)

      13.times {|n| FactoryGirl.create(:tile, status: 'active', headline: "Tile Number #{n}", demo: @demo)}
      
      visit activity_path(as: user)
      # We should have killed this chicken months ago
      page.all('#no_thanks_tutorial').to_a.select{|x| x.visible?}.first.click
    end

    it "should show the first N in the first batch" do
      expect_thumbnail_count(6)
    end

    it "should load the next N on clicking See More", js: true do
      show_more_tiles_link.click
      expect_thumbnail_count(12)

      show_more_tiles_link.click
      expect_thumbnail_count(13)

      # Hey look, here comes everybody!
      6.times {|n| FactoryGirl.create(:tile, status: 'active', headline: "Second Batch Tile #{n}", demo: @demo)}

      show_more_tiles_link.click
      expect_thumbnail_count(18)

      show_more_tiles_link.click
      expect_thumbnail_count(19)
    end
  end
end
