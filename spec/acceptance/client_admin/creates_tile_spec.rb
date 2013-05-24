require 'acceptance/acceptance_helper'

feature 'Creates tile' do
  let (:client_admin) { FactoryGirl.create(:client_admin)}
  let (:demo)         { client_admin.demo }

  def fill_in_answer_field(index, text)
    fields = page.all("input[name='tile_builder_form[answers][]']")
    fields[index].set(text)
  end

  before do
    visit new_client_admin_tile_path(as: client_admin)
  end

  scenario 'by uploading an image and supplying some information', js: true do
    demo.tiles.should be_empty
    demo.rules.should be_empty

    attach_file "tile_builder_form[image]", tile_fixture_path('cov1.jpg')
    fill_in "Headline",           with: "Ten pounds of cheese"
    fill_in "Supporting content", with: "Ten pounds of cheese. Yes? Or no?"

    fill_in "Question", with: "Who rules?"

    2.times {click_link "Add another answer"}
    fill_in_answer_field 0, "me"
    fill_in_answer_field 2, "you"

    fill_in "Points", with: "23"

    click_button "Publish tile"

    expect_content "OK, you've created a new tile."

    demo.tiles.reload.should have(1).tile
    new_tile = Tile.last
    new_tile.image_file_name.should == 'cov1.jpg'
    new_tile.thumbnail_file_name.should == 'cov1.jpg'
    new_tile.headline.should == "Ten pounds of cheese"
    new_tile.supporting_content.should == "Ten pounds of cheese. Yes? Or no?"
    new_tile.question.should == "Who rules?"

    demo.rules.reload.should have(1).rule
    new_rule = Rule.last
    new_rule.points.should == 23

    new_rule.rule_values.should have(2).rule_values
    new_rule.rule_values.pluck(:value).sort.should == %w(me you)
    new_rule.rule_values.find_by_value('me').is_primary.should be_true

    new_rule.rule_triggers.should have(1).trigger
    new_trigger = new_rule.rule_triggers.first
    new_trigger.tile.should == new_tile
  end

  scenario "with incomplete data should give a gentle rebuff", js: true do
    click_button "Publish tile"
    2.times { click_link "Add another answer" }

    demo.tiles.reload.should be_empty
    expect_content "Sorry, we couldn't save this tile: headline can't be blank, supporting content can't be blank, question can't be blank, image is missing, points can't be blank, must have at least one answer."
  end
end
