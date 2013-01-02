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

  let(:single_tile) { FactoryGirl.create :tile, demo: demo, poly: false, headline: 'Single Tile' }
  let(:or_tile)     { FactoryGirl.create :tile, demo: demo, poly: false, headline: 'Or Tile' }
  let(:and_tile)    { FactoryGirl.create :tile, demo: demo, poly: true,  headline: 'And Tile' }

  # Note the '!'s because these variables aren't referenced in the tests
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

  # My first custom matcher! Yippee!!
  RSpec::Matchers.define :be_tile do |tile|
    match do |current_tile|
      current_tile.should == tile.id.to_s
    end

    failure_message_for_should do |current_tile|
      "expected current tile to have an id of #{current_tile}, but got #{tile.id} instead "
    end

    failure_message_for_should_not do |current_tile|
      "expected current tile *not* to have an id of #{current_tile}, but that is what we got"
    end
  end

  def click_carousel_tile(tile)
    find("a[href='#{tile_path(tile)}']").click
  end

  def show_previous_tile
    page.find("#prev").click
  end

  def show_next_tile
    page.find("#next").click
  end

  def current_slideshow_tile
    sleep 0.5  # Give tile attributes time to change

    # Use the z-index to determine which tile is visible. (Not crazy about it, but since it's the only thing that works...)
    current_tile = all('#slideshow img').sort_by { |img| img[:style].slice(/(z-index: )(\d)/, 2) }.last

    current_tile[:id]  # 'current_tile' is a Capybara::Node::Element => return its 'id' attribute
  end

=begin
Tile specs (at least these tile specs) need 'js' to be 'webkit', not 'true' (which => 'poltergeist'). Why?
The first batch shows the slideshow-tile tags when using :webkit, the second batch shows those same tags when using :poltergeist
Since we need to test which tiles are visible... well, which one would you use?

<div id="slideshow">
  <img id="315" class="tile_image" style="top: 0px; left: 0px; z-index: 1; position: absolute; display: none; " src="/home/larry/RubyMine/Hengage/public/images/viewer/missing.png" alt="Single Tile">
  <img id="316" class="tile_image" style="position: absolute; top: 0px; left: 0px; z-index: 3; opacity: 1; display: inline; " src="/home/larry/RubyMine/Hengage/public/images/viewer/missing.png" alt="Or Tile">
  <img id="317" class="tile_image" style="position: absolute; top: 0px; left: 0px; display: none; z-index: 2; " src="/home/larry/RubyMine/Hengage/public/images/viewer/missing.png" alt="And Tile">
</div>

<div id="slideshow">
  <img id="318" class="tile_image" src="/home/larry/RubyMine/Hengage/public/images/viewer/missing.png" alt="Single Tile">
  <img id="319" class="tile_image" src="/home/larry/RubyMine/Hengage/public/images/viewer/missing.png" alt="Or Tile">
  <img id="320" class="tile_image" src="/home/larry/RubyMine/Hengage/public/images/viewer/missing.png" alt="And Tile">
</div>
=end

  scenario "tile should remain the same (i.e. not go back to #1) if user is not done completing multiple 'AND' triggers", js: :webkit do
    fill_in 'command_central', with: 'Ate bowl #1 of beans'
    click_button "Play"
    page.should have_content('You have eaten 1 out of 3 bowls of beans')

    click_link "Home"
    click_carousel_tile(or_tile)
    current_slideshow_tile.should be_tile(or_tile)

    show_previous_tile
    current_slideshow_tile.should be_tile(single_tile)

    show_previous_tile
    current_slideshow_tile.should be_tile(and_tile)

    show_previous_tile
    current_slideshow_tile.should be_tile(or_tile)

    show_next_tile
    current_slideshow_tile.should be_tile(and_tile)

    # TODO Uncomment either of the first statements in the groups => all steps still run to completion
    # TODO Then uncomment either of the second statements in the groups => hangs.
    # TODO But these same group of statements work upstairs. ^%$#@!$#@!!
    # TODO Well, this used to be true, but now uncommenting the first stmt. in the first group no longer passes. Sigh...

    #click_link "Home"
    #click_carousel_tile(single_tile)
    #current_slideshow_tile.should be_tile(single_tile)

    #fill_in 'command_central', with: 'Walked one mile'
    #click_button "Play"
    #page.should have_content('You have satisfied the walking requirement')
  end
end
