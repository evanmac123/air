require 'acceptance/acceptance_helper'

# Note: Can't use Poltergeist for these tests because nothing happens when you click the "Add a characteristic"
#       link - which is kinda sorta important for testing this sucker.
#

feature 'Client admin segments on characteristics' do

  let(:client_admin) { FactoryGirl.create :client_admin }
  let(:demo)         { client_admin.demo  }

  # -------------------------------------------------

  # CAN'T DO THIS IN A " before(:each) " BLOCK BECAUSE FOR SOME REASON IT JUST DOESN'T &^%$#@! WORK! AAARRRGGGHHH!!!
  #
  # But wait!, you cry. There is a call to this method in the 'background' block down below! ('backround' == 'before(:each)')
  #
  # Well, if you put the call to 'create_data' in each 'scenario' then the non-dummy characteristics (IQ and Favorite Pancake) don't
  # show up in the characteristics drop-down - and the reason for that is so fucking obvious I'm not even going to bother relaying it.
  #
  # I repeat: AAARRRGGGHHH!!!
  #
  def create_data
    demo_specific_characteristic = FactoryGirl.create(:characteristic, :discrete, demo: demo, name: 'Favorite Pancake', allowed_values: %w(blueberry strawberry kitten))
    game_agnostic_characteristic = FactoryGirl.create(:characteristic, :number, name: "IQ")

    FactoryGirl.create(:user, :claimed, points: 20, demo: demo, characteristics: {demo_specific_characteristic.id => 'strawberry', game_agnostic_characteristic.id => 87})
    FactoryGirl.create(:user, :claimed, points: 25, demo: demo, characteristics: {demo_specific_characteristic.id => 'blueberry',  game_agnostic_characteristic.id => 137})
    FactoryGirl.create(:user, :claimed, points: 30, demo: demo, characteristics: {demo_specific_characteristic.id => 'blueberry',  game_agnostic_characteristic.id => 87})

    crank_dj_clear  # Update MongoDB with the newly-created users and their characteristics
  end

  # -------------------------------------------------

  def new_segmentation_page
    new_client_admin_segmentation_path
  end

  def have_found_users(num)
    have_selector '#total-users-found', text: num.to_s
  end

  def select_characteristic(value, number = 0)
    select value, :from => "segment_column[#{number}]"
  end

  def select_operator(value, number = 0)
    select value, :from => "segment_operator[#{number}]"
  end

  def select_value(value, number = 0)
    select value, :from => "segment_value[#{number}]"
  end

  def fill_in_value(value, number = 0)
    fill_in "segment_value[#{number}]", :with => value
  end

  # -------------------------------------------------

  background do
    create_data

    bypass_modal_overlays(client_admin)
    signin_as(client_admin, client_admin.password)
    visit new_segmentation_page

    click_link 'Add a characteristic'
  end

  # -------------------------------------------------

  scenario 'can segment on dummy characteristic', js: :webkit do
    select_characteristic "Points"
    select_operator "is less than"
    fill_in_value "28"

    click_button "Find users"
    page.should have_found_users(3)
  end

  scenario 'can segment on game-agnostic characteristic', js: :webkit do
    select_characteristic "IQ"
    select_operator "is greater than"
    fill_in_value "100"

    click_button "Find users"
    page.should have_found_users(1)
  end

  scenario 'segmenting on game-specific characteristic', js: :webkit do
    select_characteristic "Favorite Pancake"
    select_operator "equals"
    select_value "blueberry"

    click_button "Find users"
    page.should have_found_users(2)
  end
end