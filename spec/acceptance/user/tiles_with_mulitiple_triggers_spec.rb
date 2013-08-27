require 'acceptance/acceptance_helper'

feature 'User interacts with single- and multiple-trigger tiles' do

  let(:demo)    { FactoryGirl.create :demo }
  let(:user)    { FactoryGirl.create :user, :claimed, demo: demo }

  let(:fish_rule) { FactoryGirl.create :rule, demo: demo,
                                              reply: 'You have satisfied the fish requirement',
                                              primary_value: FactoryGirl.create(:rule_value, value: 'Ate one fish')}

  let(:walk_rule) { FactoryGirl.create :rule, demo: demo,
                                              reply: 'You have satisfied the walking requirement',
                                              primary_value: FactoryGirl.create(:rule_value, value: 'Walked one mile')}

  let(:run_rule)  { FactoryGirl.create :rule, demo: demo,
                                              reply: 'You have satisfied the running requirement',
                                              primary_value: FactoryGirl.create(:rule_value, value: 'Ran one mile')}

  let(:beans_1_rule) { FactoryGirl.create :rule, demo: demo,
                                                 reply: 'You have eaten 1 out of 3 bowls of beans',
                                                 primary_value: FactoryGirl.create(:rule_value, value: 'Ate bowl #1 of beans')}

  let(:beans_2_rule) { FactoryGirl.create :rule, demo: demo,
                                                 reply: 'You have eaten 2 out of 3 bowls of beans',
                                                 primary_value: FactoryGirl.create(:rule_value, value: 'Ate bowl #2 of beans')}

  let(:beans_3_rule) { FactoryGirl.create :rule, demo: demo,
                                                 reply: 'You have satisfied the bowls-of-beans requirement',
                                                 primary_value: FactoryGirl.create(:rule_value, value: 'Ate bowl #3 of beans')}

  let(:single_tile) { FactoryGirl.create :tile, demo: demo, poly: false }
  let(:or_tile)     { FactoryGirl.create :tile, demo: demo, poly: false }
  let(:and_tile)    { FactoryGirl.create :tile, demo: demo, poly: true  }

  # Note the '!'s (because these variables aren't referenced in the tests)
  let!(:trigger_single) { FactoryGirl.create :rule_trigger, tile: single_tile, rule: fish_rule }

  let!(:trigger_or_1) { FactoryGirl.create :rule_trigger, tile: or_tile, rule: walk_rule }
  let!(:trigger_or_2) { FactoryGirl.create :rule_trigger, tile: or_tile, rule: run_rule }

  let!(:trigger_and_1) { FactoryGirl.create :rule_trigger, tile: and_tile, rule: beans_1_rule }
  let!(:trigger_and_2) { FactoryGirl.create :rule_trigger, tile: and_tile, rule: beans_2_rule }
  let!(:trigger_and_3) { FactoryGirl.create :rule_trigger, tile: and_tile, rule: beans_3_rule }

  before(:each) do
    bypass_modal_overlays(user)
  end

  background do
    signin_as(user, user.password)
  end

  scenario "current tile should not change (i.e. go back to tile #1) if user is not done completing multiple 'AND' triggers", js: true do
    visit activity_path
    click_carousel_tile(and_tile)

    fill_in 'command_central', with: 'Ate bowl #1 of beans'
    click_play_button
    page.should have_content('You have eaten 1 out of 3 bowls of beans')

    visit activity_path
    click_carousel_tile(or_tile)
    current_slideshow_tile.should be_tile(or_tile)

    show_previous_tile
    current_slideshow_tile.should be_tile(and_tile)

    show_previous_tile
    current_slideshow_tile.should be_tile(single_tile)

    show_previous_tile
    current_slideshow_tile.should be_tile(or_tile)

    show_next_tile
    current_slideshow_tile.should be_tile(single_tile)

    fill_in 'command_central', with: 'Walked one mile'
    click_play_button
    page.should have_content('You have satisfied the walking requirement')
  end
end
