require 'acceptance/acceptance_helper'

feature 'Carousel on Client Admin Tile Page' do
  include TileManagerHelpers

  def test_caruosel tiles, current_position = 0, offset = 1
    
  end

  let!(:admin) {FactoryGirl.create(:client_admin, share_section_intro_seen: true)}

  background do
    bypass_modal_overlays(admin)
    signin_as(admin, admin.password)
  end

  context "Move " do

  end
end