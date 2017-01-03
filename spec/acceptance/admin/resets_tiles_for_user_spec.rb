require 'acceptance/acceptance_helper'

feature 'Admin resets tiles for user' do
  scenario 'when the user is someone else' do
    user = FactoryGirl.create(:user)
    tile = FactoryGirl.create(:tile, demo: user.demo)

    FactoryGirl.create(:act, user: user, demo: user.demo)
    FactoryGirl.create(:tile_completion, user: user, tile: tile)
    expect(TileCompletion.count).to eq(1)
    expect(Act.count).to eq(1)

    visit edit_admin_demo_user_path(user.demo.id, user, as: an_admin)
    click_button "Reset tiles for this user in #{user.demo.name}"

    should_be_on edit_admin_demo_user_path(user.demo.id, user)
    expect_content "#{user.name}'s tiles for #{user.demo.name} have been reset. Associated acts have been destroyed"    
    expect(TileCompletion.count).to eq(0)
    expect(Act.count).to eq(1)
  end
end
