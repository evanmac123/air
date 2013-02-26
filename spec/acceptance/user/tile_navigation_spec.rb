require 'acceptance/acceptance_helper'

feature 'User navigates to different tiles' do
  let(:demo)    { FactoryGirl.create :demo }
  let(:user)    { FactoryGirl.create :user, :claimed, demo: demo }

  let(:fish_rule) { FactoryGirl.create :rule, demo: demo,
                                              reply: 'You have satisfied the fish requirement',
                                              primary_value: FactoryGirl.create(:rule_value, value: 'Ate one fish')}

  let(:walk_rule) { FactoryGirl.create :rule, demo: demo,
                                              reply: 'You have satisfied the walking requirement',
                                              primary_value: FactoryGirl.create(:rule_value, value: 'Walked one mile')}

  let(:beans_rule) { FactoryGirl.create :rule, demo: demo,
                                               reply: 'You have satisfied the beans requirement',
                                               primary_value: FactoryGirl.create(:rule_value, value: 'Ate one bowl of beans')}

  let(:tile_1) { FactoryGirl.create :tile, demo: demo }
  let(:tile_2) { FactoryGirl.create :tile, demo: demo }
  let(:tile_3) { FactoryGirl.create :tile, demo: demo }

  # Note the '!'s (because these variables aren't referenced in the tests)
  let!(:trigger_1) { FactoryGirl.create :rule_trigger, tile: tile_1, rule: fish_rule }
  let!(:trigger_2) { FactoryGirl.create :rule_trigger, tile: tile_2, rule: walk_rule }
  let!(:trigger_3) { FactoryGirl.create :rule_trigger, tile: tile_3, rule: beans_rule }

  before(:each) do
    bypass_modal_overlays(user)
  end

  background do
    signin_as(user, user.password)
  end

  scenario "clicking tiles in the carousel and next- and previous-tile arrows display the correct tiles", js: true do
    visit activity_path
    click_carousel_tile(tile_2)
    current_slideshow_tile.should be_tile(tile_2)

    show_previous_tile
    current_slideshow_tile.should be_tile(tile_1)

    show_previous_tile
    current_slideshow_tile.should be_tile(tile_3)

    show_previous_tile
    current_slideshow_tile.should be_tile(tile_2)

    show_next_tile
    current_slideshow_tile.should be_tile(tile_3)

    visit activity_path
    click_carousel_tile(tile_1)
    current_slideshow_tile.should be_tile(tile_1)
  end
end
