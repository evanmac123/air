require 'acceptance/acceptance_helper'

feature 'Admin resets tiles for user' do
  scenario 'when the user is someone else' do
    user = FactoryGirl.create(:user)
    rule = FactoryGirl.create(:rule, demo: user.demo)
    tile = FactoryGirl.create(:tile, demo: user.demo)
    rule_trigger = FactoryGirl.create(:rule_trigger, rule: rule, tile: tile)

    TileCompletion.count.should == 0
    FactoryGirl.create(:act, rule: rule, user: user, demo: user.demo)
    TileCompletion.count.should == 1
    Act.count.should == 2 # @act plus the game piece completion act

    visit edit_admin_demo_user_path(user.demo_id, user, as: an_admin)
    click_button "Reset tiles for this user in #{user.demo.name}"

    should_be_on edit_admin_demo_user_path(user.demo_id, user)
    expect_content "#{user.name}'s tiles for #{user.demo.name} have been reset. Associated acts have been destroyed"    
    TileCompletion.count.should == 0
    Act.count.should == 1
  end

  scenario 'to be specific, themselves' do
    user = an_admin
    rule = FactoryGirl.create(:rule, demo: user.demo)
    FactoryGirl.create(:rule_value, value: 'hey', is_primary: true, rule: rule)
    tile = FactoryGirl.create(:tile, demo: user.demo)
    rule_trigger = FactoryGirl.create(:rule_trigger, rule: rule, tile: tile)

    TileCompletion.count.should == 0
    FactoryGirl.create(:act, rule: rule, user: user, demo: user.demo)
    TileCompletion.count.should == 1
    Act.count.should == 2 # @act plus the game piece completion act

    visit admin_demo_tiles_path(user.demo, as: user)
    click_button "Reset my tiles for #{user.demo.name}"

    should_be_on admin_demo_tiles_path(user.demo)
    expect_content "#{user.name}'s tiles for #{user.demo.name} have been reset. Associated acts have been destroyed"    
    TileCompletion.count.should == 0
    Act.count.should == 1
  end
end
