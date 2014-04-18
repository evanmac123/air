require 'acceptance/acceptance_helper'

feature 'Creates tile' do
  let (:client_admin) { FactoryGirl.create(:client_admin)}
  let (:demo)         { client_admin.demo }

  def click_create_button
    click_button "Save tile"
  end

  before do
    visit new_client_admin_tile_path(as: client_admin)
    choose_question_type_and_subtype Tile::QUIZ, Tile::MULTIPLE_CHOICE
  end

  scenario 'by uploading an image and supplying some information', js: true do
    demo.tiles.should be_empty
    demo.rules.should be_empty

    create_good_tile

    demo.tiles.reload.should have(1).tile
    new_tile = MultipleChoiceTile.last
    new_tile.image_file_name.should == 'cov1.jpg'
    new_tile.thumbnail_file_name.should == 'cov1.jpg'
    new_tile.image_credit.should == "by Society"
    new_tile.headline.should == "Ten pounds of cheese"
    new_tile.supporting_content.should == "Ten pounds of cheese. Yes? Or no?"
    new_tile.question.should == "Who rules?"
    new_tile.link_address.should == "http://www.google.com/foobar"
    new_tile.correct_answer_index.should == 2
    new_tile.multiple_choice_answers.should == ["Me", "You", "He", "Add Answer Option"]
    new_tile.points.should == 18
    new_tile.should be_draft

    expect_content after_tile_save_message
    page.find("img[src='#{new_tile.image}']").should be_present
    %w(headline supporting_content question).each do |string|
      expect_content new_tile.send(string)
    end

    expect_content "23 POINTS"
    new_tile.multiple_choice_answers.each {|answer| expect_content answer}
  end

  scenario 'and Mixpanel gets a ping', js: true do
    create_good_tile
    FakeMixpanelTracker.clear_tracked_events
    crank_dj_clear

    FakeMixpanelTracker.should have_event_matching('Tile - New', client_admin.data_for_mixpanel)
  end

  scenario "does not activate tile after creating it, thus the tile appears at the front of the draft tile list", js: true do
    create_existing_tiles(demo, Tile::DRAFT, 2)

    create_good_tile
    Tile.last.should be_draft

    visit tile_manager_page

    draft_tab.should have_num_tiles(3)
   draft_tab.should have_first_tile(Tile.last, Tile::DRAFT)
  end

  scenario "shouldn't have active answer links in the preview", js: true do
    create_good_tile

    click_link "Me"
    expect_no_content "Sorry, that's not it"

    click_link "You"
    expect_no_content "That's right!"
  end

  scenario "with incomplete data should give a gentle rebuff", js: true do
    click_create_button

    demo.tiles.reload.should be_empty
    expect_content "Sorry, we couldn't save this tile: headline can't be blank, supporting content can't be blank, image is missing, points can't be blank."

    2.times { click_add_answer }
    select_correct_answer 1
    click_create_button

    demo.tiles.reload.should be_empty
    expect_content "Sorry, we couldn't save this tile: headline can't be blank, supporting content can't be blank, image is missing, points can't be blank."
  end

  scenario "with overlong headline or supporting content should have a reasonable error" do
    # We don't use a JS-based driver to test this as a quick and dirty way of 
    # simulating the behavior of certain browsers that don't respect the 
    # character counters that are supposed to keep these fields to the proper
    # length. No names, but it rhymes with Finternet Fexplorer. Thanks,
    # Ficrosoft.

    fill_in "Headline", with: ("x" * 76)
    fill_in "Supporting content", with: ("x" * 301)
    click_button "Save tile"

    demo.tiles.reload.should be_empty
    expect_content "Sorry, we couldn't save this tile"
    expect_content "headline is too long"
    expect_content "supporting content is too long"
  end

  scenario "should see character (not byte) counters on each text field", js: true do
    expect_character_counter_for      '#tile_builder_form_headline', 75
    expect_character_counter_for      '#tile_builder_form_supporting_content', 300
    expect_character_counter_for_each '.answer-field', 25

    2.times {click_add_answer}

    page.all('.quiz_content .character-counter').should have(4).counter
  end

  scenario "should start with two answer fields, rather than one", js: true do
    page.all(answer_link_selector).count.should == 2
  end

  scenario "with a survey", js: true do
    demo.tiles.should be_empty
    demo.rules.should be_empty

    fill_in_valid_form_entries(click_answer: 6, question_type: Tile::SURVEY)
    click_create_button

    demo.tiles.reload.should have(1).tile
    new_tile = MultipleChoiceTile.last
    new_tile.image_file_name.should == 'cov1.jpg'
    new_tile.thumbnail_file_name.should == 'cov1.jpg'
    new_tile.image_credit.should == "by Society"
    new_tile.headline.should == "Ten pounds of cheese"
    new_tile.supporting_content.should == "Ten pounds of cheese. Yes? Or no?"
    new_tile.question.should == "Who rules?"
    new_tile.link_address.should == "http://www.google.com/foobar"
    new_tile.correct_answer_index.should == -1
    new_tile.is_survey?.should == true
    new_tile.multiple_choice_answers.should == ["Me", "You", "He", "Add Answer Option"]
    new_tile.points.should == 23
    new_tile.should be_draft

    expect_content after_tile_save_message
    page.find("img[src='#{new_tile.image}']").should be_present
    %w(headline supporting_content question).each do |string|
      expect_content new_tile.send(string)
    end

    expect_content "23 POINTS"
    new_tile.multiple_choice_answers.each {|answer| expect_content answer}
  end

  context "acting with image" do
    before(:each) do
      fill_in_valid_form_entries 
    end

    scenario "clear the image", js: true do
      show_tile_image
      page.find(".clear_image").click
      show_tile_image_placeholder
    end

    scenario 'changing the image', js: true do
      attach_tile "tile_builder_form[image]", tile_fixture_path('cov2.jpg')
      click_create_button

      Tile.count.should == 1
      tile = Tile.first
      tile.image_file_name.should == 'cov2.jpg'

      should_be_on client_admin_tile_path(tile)
      expect_content after_tile_save_message
    end

    scenario "clear the image, upload new one and create tile", js: true do
      page.find(".clear_image").click
      attach_tile "tile_builder_form[image]", tile_fixture_path('cov2.jpg')
      click_create_button

      Tile.count.should == 1
      tile = Tile.first
      tile.image_file_name.should == 'cov2.jpg'
      expect_content after_tile_save_message
    end

    scenario "clear image, upload new but make empty fields, click update tile\
              see new image and error message, fill empty fields, \
              save tile and get new image", js:true do
      
      fill_in "Headline", with: ""
      page.find(".clear_image").click
      attach_tile "tile_builder_form[image]", tile_fixture_path('cov2.jpg')
      click_create_button

      expect_content "Sorry, we couldn't save this tile"
      fill_in "Headline", with: "head"
      click_create_button

      Tile.count.should == 1
      tile = Tile.first

      should_be_on client_admin_tile_path(tile)
      expect_content after_tile_save_message
      tile.image_file_name.should == 'cov2.jpg'
    end
  end

  context "acting with question and answers" do
    scenario "choose type Action, subtype any", js: true do
      choose_question_type_and_subtype Tile::ACTION, Tile::DO_SOMETHING
      page.all(answer_link_selector).should have(1).link
      page.all(".choose_answer").should be_empty
      page.all(".add_answer").should be_empty
    end

    scenario "choose type Quiz, subtype true/false", js: true do
      choose_question_type_and_subtype Tile::QUIZ, Tile::TRUE_FALSE
      page.all(answer_link_selector).should have(2).links
      page.find(".choose_answer").text.should == "Correct answer not selected"
      page.all(".add_answer").should be_empty
    end

    scenario "choose type Quiz, subtype multiple choice", js: true do
      choose_question_type_and_subtype Tile::QUIZ, Tile::MULTIPLE_CHOICE
      page.all(answer_link_selector).should have(2).links
      page.find(".choose_answer").text.should == "Correct answer not selected"
      page.find(".add_answer").text.should == "Add another answer"
    end

    scenario "choose type Survey, subtype multiple choice", js: true do
      choose_question_type_and_subtype Tile::SURVEY, Tile::MULTIPLE_CHOICE
      page.all(answer_link_selector).should have(2).links
      page.all(".choose_answer").should be_empty
      page.find(".add_answer").text.should == "Add another answer"
    end

    scenario "when i choose another type my answers and question on the old one are saved", js: true do
      choose_question_type_and_subtype Tile::QUIZ, Tile::MULTIPLE_CHOICE
      fill_in_question "What music do you like?"
      click_add_answer
      fill_in_answer_field 0, "Pop"
      fill_in_answer_field 1, "Rock"

      click_add_answer
      fill_in_answer_field 2, "Sock"
      select_correct_answer 2

      choose_question_type_and_subtype Tile::SURVEY, Tile::MULTIPLE_CHOICE

      choose_question_type_and_subtype Tile::QUIZ, Tile::MULTIPLE_CHOICE
      page.find(".tile_question").text.should == "What music do you like?"
      page.all(".tile_multiple_choice_answer a")[0].text.should == "Pop"
      page.all(".tile_multiple_choice_answer a")[1].text.should == "Rock"
      page.all(".tile_multiple_choice_answer a")[2].text.should == "Sock"
      page.find(".clicked_right_answer").text.should == "Sock"
    end
  end
end
