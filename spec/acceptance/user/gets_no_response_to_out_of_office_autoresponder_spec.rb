require 'acceptance/acceptance_helper'

feature 'Gets no response to out of office autoresponder' do
  scenario "system logs email but sends no response" do
    demo = FactoryGirl.create(:demo, :with_email)
    user = FactoryGirl.create(:user, demo: demo)

    out_of_office_subjects = [
      "Out of office until July 1, 2013",
      "On vacation until July 1, 2013",
      "Out-of-office until July 1, 2013",
      "Out of Office reply",
      "Out of the office for the foreseable future",
      "out-of-office for Now"
    ]

    out_of_office_bodies = [
      "I am out of the office until July 1. In case of emergency, run in circles, scream, and shout.",
      "For urgent matters, ask kim@hengage.com, since she doesn't have enough to do."
    ]

    out_of_office_subjects.each do |subject|
      out_of_office_bodies.each do |body|
        email_originated_message_received(user.email, subject, body, user.demo.email)
      end
    end

    EmailCommand.all.length.should == out_of_office_subjects.length * out_of_office_bodies.length
    EmailCommand.all.all? {|email_command| email_command.status == EmailCommand::Status::SILENT_SUCCESS}.should be_true

    crank_dj_clear
    ActionMailer::Base.deliveries.should be_empty
  end
end
