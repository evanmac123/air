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
  
  context "share to explore" do
    scenario "by default, share button is off" do
      page.find('#share_off')['checked'].should be_present
    end
    scenario "clicking the share button should display allow copy button and add tag field", js: true do
      page.should_not have_css('.allow_copying', visible: true)
      page.should_not have_css('.add_tag', visible: true)

      click_make_public
      
      page.should have_css('.allow_copying', visible: true)
      page.should have_css('.add_tag', visible: true)
    end
    
    scenario "tag is displayed after adding and is removable", js: true do
      click_make_public
      add_new_tile_tag('random tag')
      find('.tile_tags > li').should have_content('random tag')

      find('.tile_tags > li > .fa-times').click
      page.should_not have_content('random tag')
     
      page.should_not have_css('.tile_tags > li')
      click_create_button
      page.should have_content('Add a tag to continue')
    end

    scenario "displays similiar tags and add tag button if exactly same tag is not present", js: true do
      tag1 = FactoryGirl.create :tile_tag, title: "untag"
      tag2 = FactoryGirl.create :tile_tag, title: "tagged"

      click_make_public
      write_new_tile_tag "tag"

      expect_content "untag"
      expect_content "tagged"
      expect_content "Click to add."

      write_new_tile_tag "untag"
      expect_content "untag"
    end
    
    scenario 'tile with tags added is saved correctly', js: true do
      fill_in_valid_form_entries({click_answer: 1}, true)
      
#      add_new_tile_tag('first tag added', true)
#      add_new_tile_tag('second tag added')
      click_create_button
      page.status_code.should be(200)
      demo.tiles.reload.should have(1).tile
      new_tile = Tile.last
      new_tile.tile_tags.reload.where(title: 'Start tag').should_not be_empty
#      new_tile.tile_tags.reload.where(title: 'First tag added').should_not be_empty
#      new_tile.tile_tags.reload.where(title: 'Second tag added').should_not be_empty
    end
   
    context "when attempting to make a tile public but not specifying a tag" do
      scenario "pings", js: true do
        fill_in_valid_form_entries({}, false)
        click_make_public
        click_create_button
        page.should have_content("Add a tag to continue")

        FakeMixpanelTracker.clear_tracked_events
        crank_dj_clear

        FakeMixpanelTracker.should have_event_matching('Tile - New', {'action' => 'Received No Tag Added Error'})
      end
    end
  end

  scenario 'by uploading an image and supplying some information', js: true do
    demo.tiles.should be_empty
    demo.rules.should be_empty

    create_good_tile(true)
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

    expect_content "18 POINTS"
    new_tile.multiple_choice_answers.each {|answer| expect_content answer}

    new_tile.creator.should == client_admin

    new_tile.is_public.should be_true
  end

  scenario 'and Mixpanel gets a ping', js: true do
    create_good_tile
    page.status_code.should be(200)
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

  scenario "should have active answer links in the preview", js: true do
    create_good_tile

    click_link "Me"
    expect_content "Sorry, that's not it"

    click_link "He"
    expect_content "Correct!"
  end

  scenario "with incomplete data should give a gentle rebuff", js: true do
    click_create_button

    demo.tiles.reload.should be_empty
    expect_content "Sorry, we couldn't save this tile: headline can't be blank, supporting content can't be blank, image is missing."

    2.times { click_add_answer }
    select_correct_answer 1
    click_create_button

    demo.tiles.reload.should be_empty
    expect_content "Sorry, we couldn't save this tile: headline can't be blank, supporting content can't be blank, image is missing."
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
    new_tile.points.should == 18
    new_tile.should be_draft

    expect_content after_tile_save_message
    page.find("img[src='#{new_tile.image}']").should be_present
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

  context "when the public and copyable checkboxes are not checked" do
    it "should not set those", js: true do
      create_good_tile(false)
      new_tile = MultipleChoiceTile.last
      new_tile.is_public.should be_false
      new_tile.is_copyable.should be_true #by default, its value is set to true
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

    scenario "when i make tile with answer blanks and duplicates it is saved correct", js: true do
      attach_tile "tile_builder_form[image]", tile_fixture_path('cov1.jpg')
      fill_in_image_credit "by Society"
      fill_in "Headline",           with: "Ten pounds of cheese"
      fill_in "Supporting content", with: "Ten pounds of cheese. Yes? Or no?"

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
      tile.multiple_choice_answers.should == ["1", "2", "Add Answer Option"]
      tile.correct_answer_index.should == 1
    end
  end
end
