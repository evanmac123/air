require 'acceptance/acceptance_helper'

feature 'Admin sees number of referred users' do
  it "should appear on the page for the demo" do
    demo = FactoryGirl.create(:demo)
    3.times{FactoryGirl.create(:user, :claimed, :with_game_referrer, demo: demo)}
    2.times{FactoryGirl.create(:user, :claimed, demo: demo)}

    visit admin_demo_path(demo, as: an_admin)

    expect_content "3 users have credited a game referrer"
  end
end
