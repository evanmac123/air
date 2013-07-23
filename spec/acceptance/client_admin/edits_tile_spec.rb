require 'acceptance/acceptance_helper'


shared_examples_for "editing a tile" do
  scenario 'should see the tile thumbnail before editing' do
    page.find("img[src='#{@tile.thumbnail}']").should be_present
  end

  scenario 'changing the image' do
    attach_file "tile_builder_form[image]", tile_fixture_path('cov1.jpg')
    click_button "Upload new image"

    Tile.count.should == 1
    @tile.reload.image_file_name.should == 'cov1.jpg'

    should_be_on edit_client_admin_tile_path(@tile)
    expect_content "OK, you've uploaded a new image."
  end

  scenario "trying to change the image without selecting one" do
    original_image_file_name = @tile.image_file_name
    click_button "Upload new image"

    Tile.count.should == 1
    @tile.reload.image_file_name.should == original_image_file_name

    should_be_on edit_client_admin_tile_path(@tile)
    expect_content "Please select an image if you'd like to upload a new one."
  end

  scenario "tile has same status after editing that it did before", js: true do
    @tile.should be_active
    click_button "Update tile"
    expect_content "This is your finished tile."
    expect_no_content "Click here to activate it"
    @tile.reload.should be_active

    @tile.update_attributes(status: Tile::ARCHIVE)
    visit edit_client_admin_tile_path(@tile)
    click_button "Update tile"
    @tile.reload.should be_archived
  end

  scenario "activates tile after editing", js: true do
    @tile.update_attributes(status: Tile::ARCHIVE)
    click_button "Update tile"

    click_activate_link
    should_be_on client_admin_tiles_path
    @tile.reload.should be_active
  end

  scenario "edits tile again after editing", js: true do
    click_button "Update tile"
    click_link "Click here"
    should_be_on edit_client_admin_tile_path(@tile)
  end

  scenario "won't let the user blank out the last answer", js: true do
    0.upto(2).each {|n| fill_in_answer_field n, ""}
    click_button "Update tile"

    expect_content "Sorry, we couldn't update this tile: must have at least one answer"
    @tile.first_rule.reload.should have(3).rule_values # unchanged
  end
end

feature 'Client admin edits keyword tile' do
  before do
    @tile = FactoryGirl.create :keyword_tile
    rule = @tile.first_rule
    rule.rule_values.first.update_attributes(value: "value 0")
    [1, 2].each{|n| FactoryGirl.create(:rule_value, rule: rule, value: "value #{n}")}

    @client_admin = FactoryGirl.create(:client_admin, demo: @tile.demo)

    # Let's make some rules to conflict with.
    wellness_rule = FactoryGirl.create(:rule, demo_id: nil)
    FactoryGirl.create(:rule_value, value: "worked out", rule: wellness_rule)

    demo_specific_rule = FactoryGirl.create(:rule, demo: @tile.demo)
    FactoryGirl.create(:rule_value, value: "in my demo", rule: demo_specific_rule)

    visit edit_client_admin_tile_path(@tile, as: @client_admin)
  end

  it_should_behave_like "editing a tile"

  scenario "when editing answer for a rule with just one answer, leaves the new answer set to primary" do
    tile = FactoryGirl.create(:keyword_tile, demo: @client_admin.demo)
    tile.first_rule.rule_values.length.should == 1

    visit edit_client_admin_tile_path(tile, as: @client_admin)
    fill_in_answer_field 0, "woop woop"
    click_button "Update tile"

    tile.first_rule.reload.should have(1).rule_value
    rule_value = tile.first_rule.rule_values.first
    rule_value.value.should == 'woop woop'
    rule_value.is_primary.should be_true
  end

  scenario 'changing the regular fields', js: true do
    fill_in "Headline",           with: "Ten pounds of cheese"
    fill_in "Supporting content", with: "Ten pounds of cheese. Yes? Or no?"

    fill_in "Ask your players a question", with: "Who rules?"

    2.times {click_link "Add another answer"}

    # Blank out "value 0"...
    fill_in_answer_field 0, ""

    # ...leave "value 1" alone, overwrite "value 2"...
    fill_in_answer_field 2, "you"

    # ...and add two brand-new values.
    fill_in_answer_field 3, "me"
    fill_in_answer_field 4, "bob"

    fill_in "Points", with: "23"

    fill_in_external_link_field "http://example.co.uk"

    click_button "Update tile"

    @tile.reload
    @tile.headline.should == "Ten pounds of cheese"
    @tile.supporting_content.should == "Ten pounds of cheese. Yes? Or no?"
    @tile.question.should == "Who rules?"
    @tile.link_address.should == "http://example.co.uk"

    rule = @tile.first_rule
    rule.reply.should include("Ten pounds of cheese")
    rule.description.should include("Ten pounds of cheese")
    rule.points.should == 23

    rule.should have(4).rule_values
    rule.rule_values.map(&:value).sort.should == ['bob', 'me', 'value 1', 'you']
    rule.primary_value.value.should == "value 1"

    should_be_on client_admin_tile_path(@tile)
    expect_content after_tile_save_message(hide_activate_link: true)
  end

  scenario 'with bad information', js: true do
    7.times {click_link "Add another answer"}
    fill_in_answer_field 0, ""
    fill_in_answer_field 2, "you"
    fill_in_answer_field 3, "m"
    fill_in_answer_field 4, "bob"
    fill_in_answer_field 5, "worked out"
    fill_in_answer_field 6, "in my demo"
    fill_in_answer_field 7, "follow"

    fill_in "Headline",           with: ""
    fill_in "Supporting content", with: "I bet it would be cool if this tile would save"

    click_button "Update tile"

    # We want the answers we entered, in the order we gave them in.
    page.all('.answer-field').map(&:value).should == ["value 1", "you", "m", "bob", "worked out", "in my demo", "follow"]

    page.find("#tile_builder_form_headline").value.should be_blank
    page.find("#tile_builder_form_supporting_content").value.should == "I bet it would be cool if this tile would save"

    rule_values = @tile.first_rule.reload.rule_values
    rule_values.should have(3).rule_values
    rule_values.pluck(:value).sort.should == ["value 0", "value 1", "value 2"]
    expect_content "Sorry, we couldn't update this tile: headline can't be blank, answer \"m\" must have more than one letter, \"in my demo\" is already taken, \"worked out\" is already taken, \"follow\" is already taken"
  end

  scenario "should have no radio buttons" do
    page.all("input[type=radio]").should be_empty
  end
end

feature "Client admin edits multiple choice tile" do
  before do
    @tile = FactoryGirl.create :multiple_choice_tile

    @client_admin = FactoryGirl.create(:client_admin, demo: @tile.demo)

    visit edit_client_admin_tile_path(@tile, as: @client_admin)
  end

  it_should_behave_like "editing a tile"

  scenario "changing the regular fields"

  scenario "with bad information"
end
