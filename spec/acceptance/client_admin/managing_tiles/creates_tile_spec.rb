require 'acceptance/acceptance_helper'
feature 'Creates tile' do
  let (:client_admin) { FactoryGirl.create(:client_admin)}
  let (:demo)         { client_admin.demo }

  def click_create_button
    click_button "Save tile"
  end

  def normalize_spaces(string)
    # Convert all the weird spaces we use to make non-collapsing work into ordinary spaces.
    string.gsub(/[[:space:]]/, ' ')
  end

  before do
    skip
    visit new_client_admin_tile_path(as: client_admin)
    choose_question_type_and_subtype Tile::QUIZ, Tile::MULTIPLE_CHOICE
  end

  #TODO Clean up these tests they are bloated with a lot of unnecessary
  #assertions many of which should be pushed to unit tests.
  scenario 'by uploading an image and supplying some information', js: true do
    expect(demo.tiles).to be_empty

    create_good_tile
    expect(demo.tiles.reload.size).to eq(1)
    new_tile = MultipleChoiceTile.last
    expect(new_tile.image_credit).to eq("by Society")
    expect(new_tile.headline).to eq("Ten pounds of cheese")
    expect(new_tile.supporting_content).to eq("Ten pounds of cheese. Yes? Or no?")
    expect(new_tile.question).to eq("Who rules?")
    expect(new_tile.link_address).to eq("http://www.google.com/foobar")
    expect(new_tile.correct_answer_index).to eq(2)
    expect(new_tile.multiple_choice_answers).to eq(["Me", "You", "Hipster", "Add Answer Option"])
    expect(new_tile.points).to eq(18)
    expect(new_tile).to be_draft

    expect_content after_tile_save_message
    expect(page.find("img[src$='#{new_tile.image}']")).to be_present
    %w(headline supporting_content question).each do |string|
      expect_content new_tile.send(string)
    end

    expect_content "18 POINTS"
    new_tile.multiple_choice_answers.each {|answer| expect_content answer}

    expect(new_tile.creator).to eq(client_admin)

    expect(new_tile.is_public).to be_falsey # by default
  end

  scenario "does not activate tile after creating it, thus the tile appears at the front of the draft tile list", js: true do
    create_existing_tiles(demo, Tile::DRAFT, 2)

    create_good_tile
    expect(Tile.last).to be_draft

    visit tile_manager_page

    expect(draft_tab).to have_num_tiles(3)
    expect(draft_tab).to have_first_tile(Tile.last, Tile::DRAFT)
  end

  scenario "should have active answer links in the preview", js: true do
    create_good_tile

    click_link "Me"
    expect_content "Sorry, that's not it"

    click_link "Hipster"
    expect_content "Correct!"
  end

  scenario "with incomplete data should give a gentle rebuff", js: true do
    click_create_button
    expect(demo.tiles.reload).to be_empty
    expect_content "image is missing"
    expect_content "headline can't be blank"
    expect_content "supporting content can't be blank"

    2.times { click_add_answer }
    select_correct_answer 1
    click_create_button

    expect(demo.tiles.reload).to be_empty
    expect_content "image is missing"
    expect_content "headline can't be blank"
    expect_content "supporting content can't be blank"
  end

  scenario "with overlong headline should have a reasonable error" do
    # We don't use a JS-based driver to test this as a quick and dirty way of
    # simulating the behavior of certain browsers that don't respect the
    # character counters that are supposed to keep these fields to the proper
    # length. No names, but it rhymes with Finternet Fexplorer. Thanks,
    # Ficrosoft.

    fill_in "Headline", with: ("x" * 76)
    click_button "Save tile"

    expect(demo.tiles.reload).to be_empty
    expect_content "Sorry, we couldn't save this tile"
    expect_content "headline is too long"
  end

  scenario "with overlong supporting content should block submit button", js: true do
    fill_in_supporting_content("x" * 601)
    expect_content "-1 CHARACTERS"
    expect_content "Shorten the supporting content to save the Tile."
    expect(page).to have_selector("input[type=submit][value='Save tile'][disabled]")

    fill_in_supporting_content("x" * 600)
    expect_content "0 CHARACTERS"
    expect_no_content "Shorten the supporting content to save the Tile."
    expect(page).not_to have_selector("input[type=submit][value='Save tile'][disabled]")
    expect(page).to have_selector("input[type=submit][value='Save tile']")
  end

  scenario "should see character (not byte) counters on each text field", js: true do
    expect_character_counter_for      '#tile_headline', 75
    expect_character_counter_for      '#supporting_content_editor', 600
    expect_character_counter_for_each '.answer-field', 25

    2.times {click_add_answer}

    expect(page.all('.quiz_content .character-counter').size).to eq(4)
  end

  scenario "should start with two answer fields, rather than one", js: true do
    expect(page.all(answer_link_selector).count).to eq(2)
  end

  scenario "with a survey", js: true do
    expect(demo.tiles).to be_empty

    fill_in_valid_form_entries(click_answer: 6, question_type: Tile::SURVEY)
    click_create_button

    expect(demo.tiles.reload.size).to eq(1)
    new_tile = MultipleChoiceTile.last
    expect(new_tile.image_credit).to eq("by Society")
    expect(new_tile.headline).to eq("Ten pounds of cheese")
    expect(new_tile.supporting_content).to eq("Ten pounds of cheese. Yes? Or no?")
    expect(new_tile.question).to eq("Who rules?")
    expect(new_tile.link_address).to eq("http://www.google.com/foobar")
    expect(new_tile.correct_answer_index).to eq(-1)
    expect(new_tile.is_survey?).to eq(true)
    expect(new_tile.multiple_choice_answers).to eq(["Me", "You", "Hipster", "Add Answer Option"])
    expect(new_tile.points).to eq(18)
    expect(new_tile).to be_draft

    expect_content after_tile_save_message
    expect(page.find("img[src='#{new_tile.image}']")).to be_present
    %w(headline supporting_content question).each do |string|
      expect_content new_tile.send(string)
    end

    expect_content "18 POINTS"
    new_tile.multiple_choice_answers.each {|answer| expect_content answer}
  end

  context "acting with image" do
    before(:each) do
      fill_in_valid_form_entries
    end

    skip "clear the image", js: true do
      show_tile_image
      page.find(".clear_image").click
      show_tile_image_placeholder
    end

    scenario 'changing the image', js: true do

      fake_upload_image img_file1
      click_create_button
      expect_content after_tile_save_message
    end

    scenario "upload new image but make empty fields, click update tile\
              see new image and error message, fill empty fields, \
              save tile and get new image", js:true do

      fill_in "Headline", with: ""
      fake_upload_image img_file2
      click_create_button

      expect_content "Sorry, we couldn't save this tile"
      fill_in "Headline", with: "head"
      click_create_button
      expect_content after_tile_save_message
    end
  end

  context "using image library" do
    before do
      @tile_images = FactoryGirl.create_list :tile_image, 3
      crank_dj_clear
      visit new_client_admin_tile_path
      fill_in_valid_form_entries
    end

    scenario "adds image from image library", js: true do
      tile_image_block(@tile_images[0]).click
      click_create_button

      expect_content after_tile_save_message
    end
  end

  context "acting with question and answers" do
    scenario "choose type Action, subtype any", js: true do
      choose_question_type_and_subtype Tile::ACTION, Tile::TAKE_ACTION
      expect(page.all(answer_link_selector).size).to eq(1)
      expect(page.all(".choose_answer")).to be_empty
      expect(page.all(".add_answer")).to be_empty
    end

    scenario "choose type Quiz, subtype true/false", js: true do
      choose_question_type_and_subtype Tile::QUIZ, Tile::TRUE_FALSE
      expect(page.all(answer_link_selector).size).to eq(2)
      expect(page.find(".choose_answer").text).to eq("Correct answer not selected")
      expect(page.all(".add_answer")).to be_empty
    end

    scenario "choose type Quiz, subtype multiple choice", js: true do
      choose_question_type_and_subtype Tile::QUIZ, Tile::MULTIPLE_CHOICE
      expect(page.all(answer_link_selector).size).to eq(2)
      expect(page.find(".choose_answer").text).to eq("Correct answer not selected")
      expect(page.find(".add_answer").text).to eq("Add another answer")
    end

    scenario "choose type Survey, subtype multiple choice", js: true do
      choose_question_type_and_subtype Tile::SURVEY, Tile::MULTIPLE_CHOICE
      expect(page.all(answer_link_selector).size).to eq(2)
      expect(page.all(".choose_answer")).to be_empty
      expect(page.find(".add_answer").text).to eq("Add another answer")
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
      expect(page.find(".tile_question").text).to eq("What music do you like?")
      expect(page.all(".tile_multiple_choice_answer a")[0].text).to eq("Pop")
      expect(page.all(".tile_multiple_choice_answer a")[1].text).to eq("Rock")
      expect(page.all(".tile_multiple_choice_answer a")[2].text).to eq("Sock")
      expect(page.find(".clicked_right_answer").text).to eq("Sock")
    end

    scenario "when i make tile with answer blanks and duplicates it is saved correct", js: true do
      fake_upload_image img_file1
      fill_in_image_credit "by Society"
      fill_in "Headline",           with: "Ten pounds of cheese"
      fill_in_supporting_content"Ten pounds of cheese. Yes? Or no?"

      choose_question_type_and_subtype Tile::QUIZ, Tile::MULTIPLE_CHOICE

      fill_in_question "Numbers?"
      click_add_answer
      fill_in_answer_field 0, "1"
      fill_in_answer_field 1, "1"

      click_add_answer
      fill_in_answer_field 2, ""

      click_add_answer
      fill_in_answer_field 3, ""

      click_add_answer
      fill_in_answer_field 4, "2"
      select_correct_answer 4

      click_add_answer
      fill_in_answer_field 5, "2"

      click_create_button

      tile = Tile.last
      expect(tile.multiple_choice_answers).to eq(["1", "2", "Add Answer Option"])
      expect(tile.correct_answer_index).to eq(1)
    end
  end

  context "formatting in supporting content", js: true do
    it "should save supporting content with formatting and show it correctly" do
      fill_in_valid_form_entries
      supporting_content = 'The <b>origin</b> of the <a href="/wiki/Dog" target="_blank">domestic dog</a>'
      fill_in_supporting_content supporting_content
      click_create_button

      tile = Tile.last
      expect(tile.supporting_content).to eq(supporting_content)

      expect_content 'The origin of the domestic dog'
      expect(page.all(".tile_supporting_content b").count).to eq(1)
      expect(page.all(".tile_supporting_content a").count).to eq(1)
    end
  end
end
