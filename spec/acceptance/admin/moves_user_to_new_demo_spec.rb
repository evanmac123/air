require 'acceptance/acceptance_helper'

metal_testing_hack(SmsController)

feature 'Admin moves user to new demo' do
  def move_user(user, new_demo)
    visit(edit_admin_demo_user_path(user.demo, user, as: an_admin))
    select(new_demo.name, :from => 'user[demo_id]')
    click_button 'Move User'
  end

  before(:each) do
    Timecop.freeze(Time.parse("2010-05-01 12:00 EST"))

    @thoughtbot = FactoryGirl.create(:demo)
    @ibm = FactoryGirl.create(:demo)
    
    @dan = FactoryGirl.create(:user, :claimed, :with_phone_number, name: 'Dan', points: 0, privacy_level: 'everybody', demo: @thoughtbot)
    @bob = FactoryGirl.create(:user, :claimed, :with_phone_number, points: 14, privacy_level: 'everybody', demo: @ibm)
    @fred = FactoryGirl.create(:user, :claimed, :with_phone_number, points: 10, privacy_level: 'everybody', demo: @thoughtbot)
    @tom = FactoryGirl.create(:user, :claimed, :with_phone_number, points: 5, privacy_level: 'everybody', demo: @ibm)

    has_password @dan, 'foobar'
    has_password @bob, 'foobar'
    has_password @fred, 'foobar'
    has_password @tom, 'foobar'

    FactoryGirl.create(:act, user: @dan, text: 'ate banana', inherent_points: 7, created_at: Time.parse('2010-04-30 12:00 EST'))
    FactoryGirl.create(:act, user: @dan, text: 'walked dog', inherent_points: 9)

    rule = FactoryGirl.create(:rule, reply: 'run run', points: 10, demo: @ibm)
    FactoryGirl.create(:rule_value, value: 'went running', rule: rule)

    move_user(@dan, @ibm)

    mo_sms(@dan.phone_number, 'went running')
  end

  after(:each) do
    Timecop.return
  end

  scenario "User's new acts appear in the new demo" do
    visit activity_path(as: @bob)
    expect_content "10 pts Dan went running"
  end

  scenario "User's old acts don't appear in the new demo" do
    visit activity_path(as: @bob)
    expect_no_content 'Dan ate banana'
    expect_no_content 'Dan walked dog'
  end

  scenario "User's new acts don't appear in the old demo" do
    visit activity_path(as: @fred)
    expect_no_content 'Dan went running'
  end

  scenario "In user's profile page, only new acts appear" do
    visit activity_path(as: @bob)
    find('a.name-of-user', text: 'Dan').click
    expect_content 'went running'
    expect_no_content 'ate banana'
    expect_no_content 'walked dog'
  end

  scenario "User's old acts reappear when moved back to the original demo" do
    move_user @dan.reload, @thoughtbot
    visit activity_path(as: @fred)
    expect_content 'Dan ate banana'
    expect_content 'Dan walked dog'
  end

  scenario "User disappears from view in the new demo when moved back to the original demo" do
    move_user @dan.reload, @thoughtbot
    visit activity_path(as: @bob)
    expect_no_content 'Dan'
  end
end
