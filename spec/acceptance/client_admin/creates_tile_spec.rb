require 'acceptance/acceptance_helper'

feature 'Creates tile' do
  let (:client_admin) { FactoryGirl.create(:client_admin)}
  let (:demo)         { client_admin.demo }

  def expect_character_counter_for(selector, max_characters)
    counter = page.find("#{selector} + .character-counter")
    counter.text.should == "#{max_characters} characters left"
  end

  def fill_in_valid_form_entries
    attach_file "tile_builder_form[image]", tile_fixture_path('cov1.jpg')
    fill_in "Headline",           with: "Ten pounds of cheese"
    fill_in "Supporting content", with: "Ten pounds of cheese. Yes? Or no?"

    fill_in "Ask your players a question", with: "Who rules?"

    2.times {click_link "Add another answer"}
    fill_in_answer_field 0, "me"
    fill_in_answer_field 2, "you"

    fill_in "Points", with: "23"

    fill_in_external_link_field  "http://www.google.com/foobar"
  end

  before do
    visit new_client_admin_tile_path(as: client_admin)
  end

  scenario 'by uploading an image and supplying some information', js: true do
    demo.tiles.should be_empty
    demo.rules.should be_empty

    fill_in_valid_form_entries
    click_button "Publish tile"

    expect_content "OK, you've created a new tile."

    demo.tiles.reload.should have(1).tile
    new_tile = Tile.last
    new_tile.image_file_name.should == 'cov1.jpg'
    new_tile.thumbnail_file_name.should == 'cov1.jpg'
    new_tile.headline.should == "Ten pounds of cheese"
    new_tile.supporting_content.should == "Ten pounds of cheese. Yes? Or no?"
    new_tile.question.should == "Who rules?"
    new_tile.link_address.should == "http://www.google.com/foobar"

    demo.rules.reload.should have(1).rule
    new_rule = Rule.last
    new_rule.points.should == 23
    new_rule.alltime_limit.should == 1
    new_rule.reply.should == %{+23 points! Great job! You completed the "Ten pounds of cheese" tile.}
    new_rule.description.should == %{Answered a question on the "Ten pounds of cheese" tile.}

    new_rule.rule_values.should have(2).rule_values
    new_rule.rule_values.pluck(:value).sort.should == %w(me you)
    new_rule.primary_value.value.should == 'me'

    new_rule.rule_triggers.should have(1).trigger
    new_trigger = new_rule.rule_triggers.first
    new_trigger.tile.should == new_tile
  end

  scenario "previews tile after creating it", js: true do
    fill_in_valid_form_entries
    click_button "Publish tile"

    click_link "See it"

    new_tile = Tile.last
    should_be_on client_admin_tile_path(new_tile)

    page.find("img[src='#{new_tile.image}']").should be_present
    %w(headline supporting_content question).each do |string|
      expect_content new_tile.send(string)
    end

    expect_content "23 pts"
  end

  scenario "with incomplete data should give a gentle rebuff", js: true do
    click_button "Publish tile"
    2.times { click_link "Add another answer" }

    demo.tiles.reload.should be_empty
    expect_content "Sorry, we couldn't save this tile: headline can't be blank, supporting content can't be blank, question can't be blank, image is missing, points can't be blank, must have at least one answer."
  end

  scenario "should see character (not byte) counters on each text field", js: true do
    expect_character_counter_for '#tile_builder_form_headline', 45
    expect_character_counter_for '#tile_builder_form_supporting_content', 300
    expect_character_counter_for '.answer-field', 25

    2.times {click_link "Add another answer"}
    page.all('#answers .character-counter').should have(3).counters
  end

  scenario "sees a helpful error message if they try to use an existing rule or a special command for a rule value" do
    wellness_rule = FactoryGirl.create(:rule, demo_id: nil)
    FactoryGirl.create(:rule_value, value: "worked out", rule: wellness_rule)

    demo_specific_rule = FactoryGirl.create(:rule, demo_id: demo.id)
    FactoryGirl.create(:rule_value, value: "In my demo", rule: demo_specific_rule)

    fill_in_answer_field(0, 'in my demo')
    click_button "Publish tile"
    expect_content '"in my demo" is already taken'

    fill_in_answer_field(0, 'worked out')
    click_button "Publish tile"
    expect_content '"worked out" is already taken'

    # Duplicates of standard playbook rules are OK though if we're not using the standard playbook
    demo.update_attributes(use_standard_playbook: false)
    fill_in_answer_field(0, 'Worked out')
    click_button "Publish tile"
    expect_no_content '"worked out" is already taken'

    fill_in_answer_field(0, 'Follow') # a special command
    click_button "Publish tile"
    expect_content '"follow" is already taken'

    fill_in_answer_field(0, 'Q')
    click_button "Publish tile"
    expect_content 'answer "q" must have more than one letter'
  end
end
