require 'acceptance/acceptance_helper'

feature 'User views tiles' do
  def expect_supporting_content(expected_content)
    expect_content expected_content
  end

  def expect_question(question)
    expect_content question
  end

  def expect_points(points)
    expect_content "#{points} Points"
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
    expect_content "Points 10/20, Tix 1"
  end

  def show_more_tiles_link
    page.find('a.show_more_tiles')
  end

  def expect_thumbnail_count(expected_count)
    page.all('.tile-wrapper').should have(expected_count).thumbnails
  end

  def expect_placeholder_count(expected_count)
    page.all('.placeholder_tile').should have(expected_count).placeholders
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
      expect_content "completed the tile: \"#{@tile.headline}\""
      expect_content "30 PTS"
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

  {:mobile => 2, :tablet => 3, :desktop => 4}.each do |device_type, expected_tile_batch_size|
    context "loaded in batches which on #{device_type} have #{expected_tile_batch_size} tiles apiece, with a \"See More\" link" do
      before do
        spoof_client_device(device_type)
        @demo = FactoryGirl.create(:demo)
        user = FactoryGirl.create(:user, demo: @demo, sample_tile_completed: true)

        (expected_tile_batch_size * 2 + 1).times {|n| FactoryGirl.create(:tile, status: 'active', headline: "Tile Number #{n}", demo: @demo)}
        
        visit activity_path(as: user)
      end

      it "should show the first N in the first batch", js: true do
        expect_thumbnail_count(expected_tile_batch_size)
      end

      it "should load the next N on clicking See More", js: true do
        show_more_tiles_link.click
        expect_thumbnail_count(expected_tile_batch_size * 2)
        expect_placeholder_count(0)

        show_more_tiles_link.click
        expect_thumbnail_count(expected_tile_batch_size * 2 + 1)
        expect_placeholder_count(expected_tile_batch_size - 1)

        # Hey look, here comes everybody!
        expected_tile_batch_size.times {|n| FactoryGirl.create(:tile, status: 'active', headline: "Second Batch Tile #{n}", demo: @demo)}

        show_more_tiles_link.click
        expect_thumbnail_count(expected_tile_batch_size * 3)
        expect_placeholder_count(0)

        show_more_tiles_link.click
        expect_thumbnail_count(expected_tile_batch_size * 3 + 1)
        expect_placeholder_count(expected_tile_batch_size - 1)
      end
    end
  end
end
