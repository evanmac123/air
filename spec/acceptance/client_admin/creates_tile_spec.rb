require 'acceptance/acceptance_helper'

feature 'Creates tile' do
  let (:client_admin) { FactoryGirl.create(:client_admin)}
  let (:demo)         { client_admin.demo }

  def counter_selector(associated_selector)
    "#{associated_selector} + .character-counter"  
  end

  def counter_text(max_characters)
    "#{max_characters} characters left"  
  end

  def expect_counter_text(counter, max_characters)
    counter.text.should == counter_text(max_characters)
  end

  def expect_character_counter_for(selector, max_characters)
    counter = page.find(counter_selector(selector))
    expect_counter_text(counter, max_characters)
  end

  def expect_character_counter_for_each(selector, max_characters)
    page.all(counter_selector(selector)) do |counter|
      expect_counter_text(counter, max_characters)
    end
  end

  def fill_in_valid_form_entries
    attach_file "tile_builder_form[image]", tile_fixture_path('cov1.jpg')
    fill_in "Headline",           with: "Ten pounds of cheese"
    fill_in "Supporting content", with: "Ten pounds of cheese. Yes? Or no?"

    fill_in "Ask your players a question", with: "Who rules?"

    2.times {click_link "Add another answer"}
    fill_in_answer_field 0, "Me"
    fill_in_answer_field 2, "You"
    select_correct_answer 2

    fill_in "Points", with: "23"

    fill_in_external_link_field  "http://www.google.com/foobar"
  end

  def create_good_tile
    fill_in_valid_form_entries
    click_create_button
  end

  def click_create_button
    click_button "Create tile"
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
    new_tile.should be_archived

    expect_content after_tile_save_message
    page.find("img[src='#{new_tile.image}']").should be_present
    %w(headline supporting_content question).each do |string|
      expect_content new_tile.send(string)
    end

    expect_content "23 pts"
    new_tile.multiple_choice_answers.each {|answer| expect_content answer}
  end

  scenario "activates tile after creating it, and the tile appears at the front of the active tile list", js: true do
    create_existing_tiles(demo, Tile::ACTIVE, 2)

    create_good_tile
    click_activate_link
    should_be_on client_admin_tiles_path
    Tile.last.should be_active

    active_tab.should have_num_tiles(3)
    active_tab.should have_first_tile(Tile.last, Tile::ACTIVE)
  end

  scenario "does not activate tile after creating it, thus the tile appears at the front of the archive tile list", js: true do
    create_existing_tiles(demo, Tile::ARCHIVE, 2)

    create_good_tile
    Tile.last.should be_archived

    visit tile_manager_page

    archive_tab.should have_num_tiles(3)
    archive_tab.should have_first_tile(Tile.last, Tile::ARCHIVE)
  end

  scenario "edits tile after creating it", js: true do
    create_good_tile
    click_edit_link
    should_be_on edit_client_admin_tile_path(Tile.last)
  end

  scenario "shouldn't have active answer links in the preview", js: true do
    create_good_tile

    click_link "Me"
    expect_no_content "Sorry, that's not it"

    newest_tile = Tile.order("created_at DESC").first
    page.all("a[href='#{tile_completions_path(tile_id: newest_tile.id)}']").should be_empty
  end

  scenario "with incomplete data should give a gentle rebuff", js: true do
    click_create_button
    2.times { click_link "Add another answer" }
    click_button "Create tile"

    demo.tiles.reload.should be_empty
    expect_content "Sorry, we couldn't save this tile: headline can't be blank, supporting content can't be blank, question can't be blank, image is missing, points can't be blank, must have at least one answer, must select a correct answer."

    2.times { click_link "Add another answer" }
    select_correct_answer 1
    click_button "Create tile"

    demo.tiles.reload.should be_empty
    expect_content "Sorry, we couldn't save this tile: headline can't be blank, supporting content can't be blank, question can't be blank, image is missing, points can't be blank, must have at least one answer, must select a correct answer."
  end

  scenario "should see character (not byte) counters on each text field", js: true do
    expect_character_counter_for      '#tile_builder_form_headline', 45
    expect_character_counter_for      '#tile_builder_form_supporting_content', 300
    expect_character_counter_for_each '.answer-field', 25

    2.times {click_link "Add another answer"}
    page.all('#answers .character-counter').should have(4).counters
  end

  scenario "should start with two answer fields, rather than one" do
    page.all(answer_field_selector).should have(2).fields
  end

  context "a keyword tile" do
    scenario "sees a helpful error message if they try to use an existing rule or a special command for a rule value" do
      pending "it is possible to create keyword tiles again"
      wellness_rule = FactoryGirl.create(:rule, demo_id: nil)
      FactoryGirl.create(:rule_value, value: "worked out", rule: wellness_rule)

      demo_specific_rule = FactoryGirl.create(:rule, demo_id: demo.id)
      FactoryGirl.create(:rule_value, value: "In my demo", rule: demo_specific_rule)

      fill_in_answer_field(0, 'in my demo')
      click_create_button
      expect_content '"in my demo" is already taken'

      fill_in_answer_field(0, 'worked out')
      click_create_button
      expect_content '"worked out" is already taken'

      # Duplicates of standard playbook rules are OK though if we're not using the standard playbook
      demo.update_attributes(use_standard_playbook: false)
      fill_in_answer_field(0, 'Worked out')
      click_create_button
      expect_no_content '"worked out" is already taken'

      fill_in_answer_field(0, 'Follow') # a special command
      click_create_button
      expect_content '"follow" is already taken'

      fill_in_answer_field(0, 'Q')
      click_create_button
      expect_content 'answer "q" must have more than one letter'
    end
  end

  scenario "should start with two answer fields, rather than one" do
    page.all(answer_field_selector).should have(2).fields
  end
end
