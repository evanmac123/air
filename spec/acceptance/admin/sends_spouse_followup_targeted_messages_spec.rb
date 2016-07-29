require 'acceptance/acceptance_helper'

feature 'Admin sends spouse followup messages' do

  def set_up_models(options={})
    @spouse_demo = FactoryGirl.create(:demo, name: "Spouse Board")
    @primary_demo = FactoryGirl.create(:demo, name: "Primary Board", dependent_board_enabled: true, dependent_board_id: @spouse_demo.id)

    @users = []
    10.times do |i|
      @users << FactoryGirl.create(:claimed_user, points: i, demo: @demo)
    end

    @users[0..5].each { |u|
      PotentialUser.create(email: "spouase-#{u.email}", demo_id: @spouse_demo.id, primary_user_id: u.id)
    }
  end

  it "should send email to all invited spouses who are not active users", :js => true do
    Delayed::Worker.delay_jobs = false

    set_up_models

    visit admin_demo_dependent_board_path(@primary_demo, as: an_admin)

    select "potential users", from: "recipients"
    fill_in "subject", with: "potential users"
    fill_in "html_text", with: "body"
    click_button "Send Message"

    expect(ActionMailer::Base.deliveries.count).to eq(6)
  end

  it "should send email to current user when send test message to current user is selected", js: true do
    Delayed::Worker.delay_jobs = false

    @spouse_demo = FactoryGirl.create(:demo, name: "Spouse Board")
    @primary_demo = FactoryGirl.create(:demo, name: "Primary Board", dependent_board_enabled: true, dependent_board_id: @spouse_demo.id)

    visit admin_demo_dependent_board_path(@primary_demo, as: an_admin)

    select "send test message to current user", from: "recipients"
    fill_in "subject", with: "current user"
    fill_in "html_text", with: "test"
    click_button "Send Message"

    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end
end
