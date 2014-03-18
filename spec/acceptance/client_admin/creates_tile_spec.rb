require 'acceptance/acceptance_helper'

feature 'Creates tile' do
  let (:client_admin) { FactoryGirl.create(:client_admin)}
  let (:demo)         { client_admin.demo }

  def create_good_tile
    fill_in_valid_form_entries
    click_create_button
  end

  def click_create_button
    click_button "Save tile"
  end

  before do
    visit new_client_admin_tile_path(as: client_admin)
  end

  scenario 'by uploading an image and supplying some information', js: true do
    demo.tiles.should be_empty
    demo.rules.should be_empty

    create_good_tile

    demo.tiles.reload.should have(1).tile
    new_tile = MultipleChoiceTile.last
    new_tile.image_file_name.should == 'cov1.jpg'
    new_tile.thumbnail_file_name.should == 'cov1.jpg'
    new_tile.headline.should == "Ten pounds of cheese"
    new_tile.supporting_content.should == "Ten pounds of cheese. Yes? Or no?"
    new_tile.question.should == "Who rules?"
    new_tile.link_address.should == "http://www.google.com/foobar"
    new_tile.correct_answer_index.should == 1
    new_tile.multiple_choice_answers.should == %w(Me You)
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
    2.times { click_link "Add another answer" }
    click_button "Save tile"

    demo.tiles.reload.should be_empty
    expect_content "Sorry, we couldn't save this tile: headline can't be blank, supporting content can't be blank, question can't be blank, image is missing, points can't be blank, must have at least one answer."

    2.times { click_link "Add another answer" }
    select_correct_answer 1
    click_button "Save tile"

    demo.tiles.reload.should be_empty
    expect_content "Sorry, we couldn't save this tile: headline can't be blank, supporting content can't be blank, question can't be blank, image is missing, points can't be blank, must have at least one answer."
  end

  scenario "should see character (not byte) counters on each text field", js: true do
    expect_character_counter_for      '#tile_builder_form_headline', 75
    expect_character_counter_for      '#tile_builder_form_supporting_content', 300
    expect_character_counter_for_each '.answer-field', 25

    2.times {click_link "Add another answer"}
    page.all('#answers .character-counter').should have(4).counters
  end

  scenario "should start with two answer fields, rather than one" do
    page.all(answer_field_selector).should have(2).fields
  end

  scenario "should start with two answer fields, rather than one" do
    page.all(answer_field_selector).should have(2).fields
  end

  scenario "with a survey", js: true do
    demo.tiles.should be_empty
    demo.rules.should be_empty

    fill_in_valid_form_entries(6)
    click_create_button

    demo.tiles.reload.should have(1).tile
    new_tile = MultipleChoiceTile.last
    new_tile.image_file_name.should == 'cov1.jpg'
    new_tile.thumbnail_file_name.should == 'cov1.jpg'
    new_tile.headline.should == "Ten pounds of cheese"
    new_tile.supporting_content.should == "Ten pounds of cheese. Yes? Or no?"
    new_tile.question.should == "Who rules?"
    new_tile.link_address.should == "http://www.google.com/foobar"
    new_tile.correct_answer_index.should == -1
    new_tile.is_survey?.should == true
    new_tile.multiple_choice_answers.should == %w(Me You)
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
end
